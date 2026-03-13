math.randomseed(os.time())

local activeEvents = {}   -- { id, zone, type, source, expiry }
local nextId       = 1

-- ─── Утилиты ──────────────────────────────────────────────────────────────────

-- Возвращает source ближайшего к pos игрока и дистанцию до него
local function ClosestPlayer(pos)
    local best, bestDist = nil, math.huge
    for _, src in ipairs(GetPlayers()) do
        local coords = GetEntityCoords(GetPlayerPed(tonumber(src)))
        local dist   = #(vector3(coords.x, coords.y, coords.z) - pos)
        if dist < bestDist then
            best, bestDist = tonumber(src), dist
        end
    end
    return best, bestDist
end

-- Взвешенный случайный выбор типа события
local function PickType()
    local total = 0
    for _, cfg in pairs(Config.Events) do
        if cfg.enabled then total = total + cfg.weight end
    end
    local r, acc = math.random() * total, 0
    for key, cfg in pairs(Config.Events) do
        if cfg.enabled then
            acc = acc + cfg.weight
            if r <= acc then return key end
        end
    end
end

-- ─── Сетевые события ──────────────────────────────────────────────────────────

-- Клиент подтверждает спавн (опционально, для отладки)
RegisterNetEvent("varta_ambient:sv:spawned")
AddEventHandler("varta_ambient:sv:spawned", function(eventId)
    -- print(("[varta_ambient] Клиент %s подтвердил событие #%d"):format(source, eventId))
end)

-- Если игрок-"хозяин" отключился — убираем его события из таблицы
-- (NPC удалятся сами при дисконнекте владельца)
AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    for i = #activeEvents, 1, -1 do
        if activeEvents[i].source == src then
            table.remove(activeEvents, i)
        end
    end
end)

-- ─── Главный цикл ─────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(15000)   -- проверяем каждые 15 секунд

        if #GetPlayers() == 0 then goto continue end

        local now       = os.time()
        local usedZones = {}

        -- Удаляем истёкшие события, просим клиента убрать NPC
        for i = #activeEvents, 1, -1 do
            local ev = activeEvents[i]
            if now >= ev.expiry then
                TriggerClientEvent("varta_ambient:cl:cleanup", ev.source, ev.id)
                table.remove(activeEvents, i)
            else
                usedZones[ev.zone] = true
            end
        end

        -- Спавним новые события в зонах без активных
        for _, zone in ipairs(Config.SpawnZones) do
            if #activeEvents >= Config.MaxEvents then break end
            if usedZones[zone.name] then goto nextZone end

            local src, dist = ClosestPlayer(zone.pos)
            if src and dist < zone.radius + Config.SpawnDistance then
                local t  = PickType()
                local id = nextId; nextId = nextId + 1

                activeEvents[#activeEvents + 1] = {
                    id     = id,
                    zone   = zone.name,
                    type   = t,
                    source = src,
                    expiry = now + Config.Events[t].duration,
                }

                TriggerClientEvent("varta_ambient:cl:spawnEvent", src, id, t, zone.pos)
                print(("[varta_ambient] Событие #%d '%s' → игрок %d (%s)"):format(id, t, src, zone.name))
            end

            ::nextZone::
        end

        ::continue::
    end
end)
