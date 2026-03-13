local VORPcore = {}
TriggerEvent("getCore", function(core) VORPcore = core end)

local spawnedPeds = {}
local menuOpen    = false
local hasSpawned  = false
local MenuData    = exports.vorp_menu:GetMenuData()

-- ─────────────────────────────────────────────
-- Prompt setup (native RedM prompts, like vorp_stores)
-- ─────────────────────────────────────────────

local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptOpen

local function setupPrompt()
    PromptOpen = UiPromptRegisterBegin()
    UiPromptSetControlAction(PromptOpen, Config.MenuKey)
    local label = VarString(10, "LITERAL_STRING", "Talk to bartender")
    UiPromptSetText(PromptOpen, label)
    UiPromptSetEnabled(PromptOpen, true)
    UiPromptSetVisible(PromptOpen, true)
    UiPromptSetStandardMode(PromptOpen, true)
    UiPromptSetGroup(PromptOpen, PromptGroup, 0)
    UiPromptRegisterEnd(PromptOpen)
end

-- ─────────────────────────────────────────────
-- Distance helper (like vorp_stores)
-- ─────────────────────────────────────────────

local function getDistanceToCoords(coords)
    local playerPos = GetEntityCoords(PlayerPedId())
    return #(playerPos - vector3(coords.x, coords.y, coords.z))
end

-- ─────────────────────────────────────────────
-- Spawn a single bartender NPC (based on vorp_stores SpawnNPC)
-- ─────────────────────────────────────────────

local function spawnBartender(key, saloon)
    local coords = saloon.bartender
    local model  = saloon.model or Config.PedModel

    if not IsModelValid(model) then
        print("[vorp_bartenders] ERROR: invalid model for " .. key)
        return
    end

    if not HasModelLoaded(model) then
        RequestModel(model, false)
        local timeout = 0
        repeat
            Wait(100)
            timeout = timeout + 100
        until HasModelLoaded(model) or timeout > 10000

        if not HasModelLoaded(model) then
            print("[vorp_bartenders] ERROR: model failed to load for " .. key)
            return
        end
    end

    local ped = CreatePed(model, coords.x, coords.y, coords.z, saloon.heading, false, false, false, false)

    -- Wait until ped actually exists (like vorp_stores)
    local waitTime = 0
    repeat Wait(100); waitTime = waitTime + 100 until DoesEntityExist(ped) or waitTime > 5000

    if not DoesEntityExist(ped) then
        print("[vorp_bartenders] ERROR: failed to create ped for " .. key)
        return
    end

    Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- SetRandomOutfitVariation (named function doesn't exist in RedM)
    PlaceEntityOnGroundProperly(ped)
    Wait(10)
    SetEntityCanBeDamaged(ped, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)

    spawnedPeds[key] = ped
    print("[vorp_bartenders] Spawned bartender at " .. key)
end

-- ─────────────────────────────────────────────
-- Menu via vorp_menu
-- ─────────────────────────────────────────────

local function openBarMenu(key)
    if menuOpen then return end
    menuOpen = true

    local saloon   = Config.Saloons[key]
    local elements = {}

    for i, drink in ipairs(saloon.drinks) do
        elements[#elements + 1] = {
            label = drink.label .. "  ~g~$" .. drink.price,
            value = i,
        }
    end
    elements[#elements + 1] = { label = "~r~Leave", value = 0 }

    MenuData.Open('default', GetCurrentResourceName(), 'bartender_' .. key, {
        title    = saloon.name,
        subtext  = "What'll it be, stranger?",
        align    = "top-left",
        elements = elements,
    }, function(data, menu)
        local idx = data.current.value
        if idx and idx > 0 then
            TriggerServerEvent("vorp_bartenders:buyDrink", key, idx)
        end
        MenuData.CloseAll()
        menuOpen = false
    end, function(data, menu)
        MenuData.CloseAll()
        menuOpen = false
    end)
end

-- ─────────────────────────────────────────────
-- Blips (native RedM, like vorp_stores)
-- ─────────────────────────────────────────────

local blipHandles = {}

local function createBlips()
    if not Config.ShowBlips then return end
    for _, saloon in pairs(Config.Saloons) do
        local c    = saloon.bartender
        local blip = BlipAddForCoords(1664425300, c.x, c.y, c.z)
        SetBlipSprite(blip, Config.BlipSprite, false)
        SetBlipName(blip, saloon.name)
        blipHandles[#blipHandles + 1] = blip
    end
end

-- ─────────────────────────────────────────────
-- Init bartenders
-- ─────────────────────────────────────────────

local function initBartenders()
    if hasSpawned then return end
    hasSpawned = true

    Wait(5000)

    print("[vorp_bartenders] Spawning bartenders...")

    for key, saloon in pairs(Config.Saloons) do
        spawnBartender(key, saloon)
        Wait(200)
    end

    setupPrompt()
    createBlips()

    print("[vorp_bartenders] All bartenders ready.")
end

-- ─────────────────────────────────────────────
-- Login detection (vorp:SelectedCharacter, like juSa_static_NPCs)
-- ─────────────────────────────────────────────

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function()
    print("[vorp_bartenders] Detected login via vorp:SelectedCharacter")
    CreateThread(initBartenders)
end)

-- Fallback: if event didn't fire, check after 30 seconds
CreateThread(function()
    Wait(30000)
    if not hasSpawned then
        local ped = PlayerPedId()
        if ped and ped ~= 0 and DoesEntityExist(ped) then
            print("[vorp_bartenders] Fallback: player ped exists, spawning bartenders")
            initBartenders()
        end
    end
end)

-- ─────────────────────────────────────────────
-- Main loop: distance check + prompt (like vorp_stores)
-- ─────────────────────────────────────────────

CreateThread(function()
    while true do
        local sleep = 1000

        if hasSpawned and not menuOpen then
            for key, saloon in pairs(Config.Saloons) do
                local dist = getDistanceToCoords(saloon.bartender)

                if dist <= Config.InteractDistance then
                    sleep = 0
                    local groupName = VarString(10, "LITERAL_STRING", saloon.name)
                    UiPromptSetActiveGroupThisFrame(PromptGroup, groupName, 0, 0, 0, 0)

                    if UiPromptHasStandardModeCompleted(PromptOpen, 0) then
                        Wait(100)
                        openBarMenu(key)
                    end
                    break -- only interact with closest one
                end
            end
        end

        Wait(sleep)
    end
end)

-- ─────────────────────────────────────────────
-- Debug commands
-- ─────────────────────────────────────────────

RegisterCommand("spawnbar2", function(source, args)
    local key = args[1] or "NoName"
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TriggerEvent("chat:addMessage", {
        args = { "^2[DEBUG]", "Coords sent to F8 console." }
    })

    print("------------------------------------------")
    print("COPY THIS TO CONFIG.LUA:")
    print(string.format("bartender = { x = %.2f, y = %.2f, z = %.2f },", coords.x, coords.y, coords.z))
    print(string.format("heading = %.2f,", heading))
    print("------------------------------------------")

    local model = GetHashKey("U_M_M_BARTENDER_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    CreatePed(model, coords.x, coords.y, coords.z, heading, false, false, false, false)
end, false)

-- ─────────────────────────────────────────────
-- Cleanup
-- ─────────────────────────────────────────────

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, blip in ipairs(blipHandles) do
        RemoveBlip(blip)
    end
    if PromptOpen then
        UiPromptDelete(PromptOpen)
    end
end)
