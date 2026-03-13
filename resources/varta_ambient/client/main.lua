local activeEvents = {}
local eventTimer   = 0

-- ─── Утилиты ──────────────────────────────────────────────────────────────────

local function LoadModel(model)
    local hash = joaat(model)
    RequestModel(hash, false)
    local timeout = 0
    repeat
        Wait(100)
        timeout = timeout + 100
    until HasModelLoaded(hash) or timeout > 5000
    if not HasModelLoaded(hash) then
        print("^1[varta_ambient] Не удалось загрузить модель: " .. model)
        return nil
    end
    return hash
end

local function SpawnNPC(model, pos, heading)
    local hash = LoadModel(model)
    if not hash then return nil end
    local ped = CreatePed(hash, pos.x, pos.y, pos.z, heading, true, true, false, false)
    repeat Wait(50) until DoesEntityExist(ped)
    SetRandomOutfitVariation(ped, true)
    PlaceEntityOnGroundProperly(ped)
    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function RandomOffset(minDist, maxDist)
    local angle = math.random() * math.pi * 2
    local dist  = minDist + math.random() * (maxDist - minDist)
    return vector3(math.cos(angle) * dist, math.sin(angle) * dist, 0.0)
end

local function RandomModel(list)
    return list[math.random(#list)]
end

-- ─── Событие: Драка ───────────────────────────────────────────────────────────

local function CreateFightEvent(center)
    local pos  = center + RandomOffset(20.0, 50.0)
    local ped1 = SpawnNPC(RandomModel(Config.Models.males), pos + vector3( 2.0, 0.0, 0.0), 270.0)
    local ped2 = SpawnNPC(RandomModel(Config.Models.males), pos + vector3(-2.0, 0.0, 0.0),  90.0)

    if not ped1 or not ped2 then
        if ped1 then DeleteEntity(ped1) end
        if ped2 then DeleteEntity(ped2) end
        return nil
    end

    SetBlockingOfNonTemporaryEvents(ped1, false)
    SetBlockingOfNonTemporaryEvents(ped2, false)
    TaskCombatPed(ped1, ped2, 0, 16)
    TaskCombatPed(ped2, ped1, 0, 16)

    return {
        type     = "fight",
        peds     = { ped1, ped2 },
        pos      = pos,
        created  = GetGameTimer(),
        duration = Config.Events.fight.duration * 1000,
    }
end

-- ─── Событие: Пьяный прохожий ─────────────────────────────────────────────────

local function CreateDrunkEvent(center)
    local pos = center + RandomOffset(15.0, 60.0)
    local ped = SpawnNPC(RandomModel(Config.Models.males), pos, math.random() * 360.0)
    if not ped then return nil end

    -- Свободное блуждание; SetBlockingOfNonTemporaryEvents(false) позволяет
    -- педу реагировать на выстрелы и других NPC
    SetBlockingOfNonTemporaryEvents(ped, false)
    TaskWanderStandard(ped, 5.0, 10)

    return {
        type     = "drunk",
        peds     = { ped },
        pos      = pos,
        created  = GetGameTimer(),
        duration = Config.Events.drunk.duration * 1000,
    }
end

-- ─── Событие: Погоня ──────────────────────────────────────────────────────────

local function CreateChaseEvent(center)
    local pos    = center + RandomOffset(30.0, 70.0)
    local outlaw = SpawnNPC(RandomModel(Config.Models.outlaws), pos,                              math.random() * 360.0)
    local law1   = SpawnNPC(RandomModel(Config.Models.law),    pos + vector3(14.0,  5.0, 0.0), 200.0)
    local law2   = SpawnNPC(RandomModel(Config.Models.law),    pos + vector3(14.0, -5.0, 0.0), 200.0)

    if not outlaw then
        if law1 then DeleteEntity(law1) end
        if law2 then DeleteEntity(law2) end
        return nil
    end

    local pistol = joaat("weapon_revolver_cattleman")
    local peds   = { outlaw }

    if law1 then
        GiveWeaponToPed(law1, pistol, 24, false, true)
        SetBlockingOfNonTemporaryEvents(law1, false)
        TaskCombatPed(law1, outlaw, 0, 16)
        peds[#peds + 1] = law1
    end
    if law2 then
        GiveWeaponToPed(law2, pistol, 24, false, true)
        SetBlockingOfNonTemporaryEvents(law2, false)
        TaskCombatPed(law2, outlaw, 0, 16)
        peds[#peds + 1] = law2
    end

    -- Беглец убегает от ближайшего стражника
    -- TaskSmartFleePed(ped, fromPed, distance, fleeTime, onFoot, unknown)
    SetBlockingOfNonTemporaryEvents(outlaw, false)
    local chaser = law1 or law2
    if chaser then
        TaskSmartFleePed(outlaw, chaser, 300.0, -1, false, false)
    else
        TaskWanderStandard(outlaw, 10.0, 10)
    end

    return {
        type     = "chase",
        peds     = peds,
        pos      = pos,
        created  = GetGameTimer(),
        duration = Config.Events.chase.duration * 1000,
    }
end

-- ─── Менеджер событий ─────────────────────────────────────────────────────────

local function CleanupEvent(event)
    for _, ped in ipairs(event.peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end

-- Взвешенный случайный выбор из Config.Events
local function PickEventType()
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

-- Найти ближайшую зону и вернуть её вместе с дистанцией
local function NearestZone(playerPos)
    local zone, dist = nil, math.huge
    for _, z in ipairs(Config.SpawnZones) do
        local d = #(playerPos - z.pos)
        if d < dist then zone, dist = z, d end
    end
    return zone, dist
end

local function TrySpawnEvent(playerPos)
    local zone, zoneDist = NearestZone(playerPos)
    if not zone or zoneDist > zone.radius + Config.SpawnDistance then return nil end

    local chosen = PickEventType()
    if     chosen == "fight" then return CreateFightEvent(zone.pos)
    elseif chosen == "drunk" then return CreateDrunkEvent(zone.pos)
    elseif chosen == "chase" then return CreateChaseEvent(zone.pos)
    end
end

-- ─── Главный поток ────────────────────────────────────────────────────────────

CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    Wait(2000)

    while true do
        Wait(5000)

        local playerPos = GetEntityCoords(PlayerPedId())
        local now       = GetGameTimer()

        -- Очищаем истёкшие или далёкие события
        for i = #activeEvents, 1, -1 do
            local ev = activeEvents[i]
            if now - ev.created > ev.duration
            or #(playerPos - ev.pos) > Config.DespawnDistance then
                CleanupEvent(ev)
                table.remove(activeEvents, i)
            end
        end

        -- Пробуем спавнить новое событие по таймеру
        eventTimer = eventTimer + 5
        if eventTimer >= Config.EventInterval and #activeEvents < Config.MaxEvents then
            local ev = TrySpawnEvent(playerPos)
            if ev then
                activeEvents[#activeEvents + 1] = ev
                eventTimer = 0
                print(("[varta_ambient] Событие '%s' создано"):format(ev.type))
            end
        end
    end
end)

-- ─── Очистка при остановке ресурса ────────────────────────────────────────────

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ev in ipairs(activeEvents) do CleanupEvent(ev) end
    activeEvents = {}
end)
