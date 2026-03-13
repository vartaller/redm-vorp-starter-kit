-- spawnedPeds[eventId] = { ped, ped, ... }
local spawnedPeds = {}

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

-- isNetwork = true → NPC синхронизируется на всех игроков
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

local function RandOffset(minD, maxD)
    local a = math.random() * math.pi * 2
    local d = minD + math.random() * (maxD - minD)
    return vector3(math.cos(a) * d, math.sin(a) * d, 0.0)
end

local function RandModel(t) return t[math.random(#t)] end

-- ─── Типы событий ─────────────────────────────────────────────────────────────

local function SpawnFight(center)
    local pos  = center + RandOffset(20.0, 50.0)
    local ped1 = SpawnNPC(RandModel(Config.Models.males), pos + vector3( 2.0, 0.0, 0.0), 270.0)
    local ped2 = SpawnNPC(RandModel(Config.Models.males), pos + vector3(-2.0, 0.0, 0.0),  90.0)

    if not ped1 or not ped2 then
        if ped1 then DeleteEntity(ped1) end
        if ped2 then DeleteEntity(ped2) end
        return {}
    end

    SetBlockingOfNonTemporaryEvents(ped1, false)
    SetBlockingOfNonTemporaryEvents(ped2, false)
    TaskCombatPed(ped1, ped2, 0, 16)
    TaskCombatPed(ped2, ped1, 0, 16)

    return { ped1, ped2 }
end

local function SpawnDrunk(center)
    local pos = center + RandOffset(15.0, 60.0)
    local ped = SpawnNPC(RandModel(Config.Models.males), pos, math.random() * 360.0)
    if not ped then return {} end
    SetBlockingOfNonTemporaryEvents(ped, false)
    TaskWanderStandard(ped, 5.0, 10)
    return { ped }
end

local function SpawnChase(center)
    local pos    = center + RandOffset(30.0, 70.0)
    local outlaw = SpawnNPC(RandModel(Config.Models.outlaws), pos, math.random() * 360.0)
    local law1   = SpawnNPC(RandModel(Config.Models.law), pos + vector3(14.0,  5.0, 0.0), 200.0)
    local law2   = SpawnNPC(RandModel(Config.Models.law), pos + vector3(14.0, -5.0, 0.0), 200.0)

    if not outlaw then
        if law1 then DeleteEntity(law1) end
        if law2 then DeleteEntity(law2) end
        return {}
    end

    local pistol = joaat("weapon_revolver_cattleman")
    local peds   = { outlaw }

    for _, law in ipairs({ law1, law2 }) do
        if law then
            GiveWeaponToPed(law, pistol, 24, false, true)
            SetBlockingOfNonTemporaryEvents(law, false)
            TaskCombatPed(law, outlaw, 0, 16)
            peds[#peds + 1] = law
        end
    end

    SetBlockingOfNonTemporaryEvents(outlaw, false)
    TaskSmartFleePed(outlaw, law1 or law2, 300.0, -1, false, false)

    return peds
end

local function SpawnBrawl(center)
    local pos   = center + RandOffset(20.0, 50.0)
    local count = math.random(3, 4)
    local peds  = {}

    for i = 1, count do
        local angle  = (i - 1) * (math.pi * 2 / count)
        local offset = vector3(math.cos(angle) * 2.5, math.sin(angle) * 2.5, 0.0)
        local ped    = SpawnNPC(RandModel(Config.Models.males), pos + offset, math.random() * 360.0)
        if ped then
            SetBlockingOfNonTemporaryEvents(ped, false)
            peds[#peds + 1] = ped
        end
    end

    if #peds < 2 then
        for _, p in ipairs(peds) do DeleteEntity(p) end
        return {}
    end

    -- Каждый бьёт следующего по кругу
    for i, ped in ipairs(peds) do
        TaskCombatPed(ped, peds[i % #peds + 1], 0, 16)
    end

    return peds
end

local function SpawnBody(center)
    local pos = center + RandOffset(10.0, 50.0)
    local ped = SpawnNPC(RandModel(Config.Models.males), pos, math.random() * 360.0)
    if not ped then return {} end
    Wait(300)
    SetEntityHealth(ped, 0, 0)
    return { ped }
end

local function SpawnRobbery(center)
    local pos    = center + RandOffset(20.0, 50.0)
    local bandit = SpawnNPC(RandModel(Config.Models.outlaws), pos,                               math.random() * 360.0)
    local victim = SpawnNPC(RandModel(Config.Models.males),   pos + vector3(4.0, 0.0, 0.0), 180.0)

    if not bandit or not victim then
        if bandit then DeleteEntity(bandit) end
        if victim then DeleteEntity(victim) end
        return {}
    end

    GiveWeaponToPed(bandit, joaat("weapon_revolver_cattleman"), 6, false, true)
    SetBlockingOfNonTemporaryEvents(bandit, false)
    SetBlockingOfNonTemporaryEvents(victim, false)
    TaskCombatPed(bandit, victim, 0, 16)
    TaskSmartFleePed(victim, bandit, 300.0, -1, false, false)

    return { bandit, victim }
end

local function SpawnArgument(center)
    local pos  = center + RandOffset(15.0, 50.0)
    -- Спавним лицом друг к другу (heading 270 и 90)
    local ped1 = SpawnNPC(RandModel(Config.Models.males), pos + vector3( 1.5, 0.0, 0.0), 270.0)
    local ped2 = SpawnNPC(RandModel(Config.Models.males), pos + vector3(-1.5, 0.0, 0.0),  90.0)

    if not ped1 or not ped2 then
        if ped1 then DeleteEntity(ped1) end
        if ped2 then DeleteEntity(ped2) end
        return {}
    end

    SetBlockingOfNonTemporaryEvents(ped1, false)
    SetBlockingOfNonTemporaryEvents(ped2, false)
    -- Сценарий "стоять нетерпеливо" — если не загрузится, просто стоят
    TaskStartScenarioInPlace(ped1, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    TaskStartScenarioInPlace(ped2, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    return { ped1, ped2 }
end

-- ─── События с животными (спавн на окраине — большой отступ) ─────────────────

local function SpawnWolfPack(center)
    local pos    = center + RandOffset(100.0, 200.0)
    local victim = SpawnNPC(RandModel(Config.Models.males), pos, math.random() * 360.0)
    local peds   = {}

    for i = 1, math.random(2, 3) do
        local offset = vector3((math.random() - 0.5) * 12.0, (math.random() - 0.5) * 12.0, 0.0)
        local wolf   = SpawnNPC(RandModel(Config.Models.wolves), pos + offset, math.random() * 360.0)
        if wolf then
            SetBlockingOfNonTemporaryEvents(wolf, false)
            if victim then TaskCombatPed(wolf, victim, 0, 16) end
            peds[#peds + 1] = wolf
        end
    end

    if victim then
        SetBlockingOfNonTemporaryEvents(victim, false)
        if peds[1] then TaskSmartFleePed(victim, peds[1], 300.0, -1, false, false) end
        peds[#peds + 1] = victim
    end

    return peds
end

local function SpawnBearSighting(center)
    local pos  = center + RandOffset(100.0, 200.0)
    local bear = SpawnNPC(RandModel(Config.Models.bears), pos, math.random() * 360.0)
    if not bear then return {} end
    SetBlockingOfNonTemporaryEvents(bear, false)
    TaskWanderStandard(bear, 10.0, 10)
    return { bear }
end

local function SpawnRunawayHorse(center)
    local pos   = center + RandOffset(100.0, 200.0)
    local horse = SpawnNPC(RandModel(Config.Models.horses), pos, math.random() * 360.0)
    if not horse then return {} end
    SetBlockingOfNonTemporaryEvents(horse, false)
    TaskWanderStandard(horse, 15.0, 5)
    return { horse }
end

-- ─── Приём событий от сервера ─────────────────────────────────────────────────

RegisterNetEvent("varta_ambient:cl:spawnEvent")
AddEventHandler("varta_ambient:cl:spawnEvent", function(eventId, eventType, zonePos)
    local peds = {}

    if     eventType == "fight"    then peds = SpawnFight(zonePos)
    elseif eventType == "drunk"    then peds = SpawnDrunk(zonePos)
    elseif eventType == "chase"    then peds = SpawnChase(zonePos)
    elseif eventType == "brawl"    then peds = SpawnBrawl(zonePos)
    elseif eventType == "body"     then peds = SpawnBody(zonePos)
    elseif eventType == "robbery"  then peds = SpawnRobbery(zonePos)
    elseif eventType == "argument"      then peds = SpawnArgument(zonePos)
    elseif eventType == "wolf_pack"     then peds = SpawnWolfPack(zonePos)
    elseif eventType == "bear_sighting" then peds = SpawnBearSighting(zonePos)
    elseif eventType == "runaway_horse" then peds = SpawnRunawayHorse(zonePos)
    end

    spawnedPeds[eventId] = peds
    print(("[varta_ambient] #%d '%s' → %d NPC"):format(eventId, eventType, #peds))
    TriggerServerEvent("varta_ambient:sv:spawned", eventId)
end)

RegisterNetEvent("varta_ambient:cl:cleanup")
AddEventHandler("varta_ambient:cl:cleanup", function(eventId)
    local peds = spawnedPeds[eventId]
    if not peds then return end
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    spawnedPeds[eventId] = nil
end)

-- ─── Очистка при остановке ресурса ────────────────────────────────────────────

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, peds in pairs(spawnedPeds) do
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) then DeleteEntity(ped) end
        end
    end
    spawnedPeds = {}
end)
