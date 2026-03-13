local Core     <const> = exports.vorp_core:GetCore()
local MenuData <const> = exports.vorp_menu:GetMenuData()

local PromptGroup <const> = GetRandomIntInRange(0, 0xffffff)
local Prompt               = nil
local isInMenu             = false

-- ─── Prompt ──────────────────────────────────────────────────────────────────

local function SetupPrompt()
    Prompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(Prompt, Config.Key)
    UiPromptSetText(Prompt, VarString(10, 'LITERAL_STRING', "Поговорить с доктором"))
    UiPromptSetEnabled(Prompt, true)
    UiPromptSetVisible(Prompt, true)
    UiPromptSetStandardMode(Prompt, true)
    UiPromptSetGroup(Prompt, PromptGroup, 0)
    UiPromptRegisterEnd(Prompt)
end

-- ─── NPC ─────────────────────────────────────────────────────────────────────

local function SpawnNPC(loc)
    local model = joaat(loc.model)

    RequestModel(model, false)
    local timeout = 0
    repeat
        Wait(100)
        timeout = timeout + 100
    until HasModelLoaded(model) or timeout > 5000

    if not HasModelLoaded(model) then
        print("^1[varta_medic] Не удалось загрузить модель: " .. loc.model)
        return nil
    end

    local ped = CreatePed(model, loc.npc.x, loc.npc.y, loc.npc.z, loc.npc.w, false, false, false, false)
    repeat Wait(100) until DoesEntityExist(ped)

    SetRandomOutfitVariation(ped, true)
    PlaceEntityOnGroundProperly(ped)
    SetEntityCanBeDamaged(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    return ped
end

-- ─── Healing ─────────────────────────────────────────────────────────────────

local function ApplyHeal(healType)
    local ped    = PlayerPedId()
    local player = PlayerId()

    if healType == "heal" or healType == "full" then
        local amount = (healType == "full") and Config.HealValues.full or Config.HealValues.health
        local inner  = GetAttributeCoreValue(ped, 0)
        if inner > 99 then
            SetEntityHealth(ped, math.floor(GetPlayerHealth(player)) + 100 + amount, 0)
        else
            SetAttributeCoreValue(ped, 0, math.min(inner + amount, 100))
        end
    end

    if healType == "stamina" or healType == "full" then
        local amount = (healType == "full") and Config.HealValues.full or Config.HealValues.stamina
        local inner  = GetAttributeCoreValue(ped, 1)
        if inner > 99 then
            ChangePedStamina(ped, amount + 0.0)
        else
            SetAttributeCoreValue(ped, 1, math.min(inner + amount, 100))
        end
    end
end

-- ─── Menu ─────────────────────────────────────────────────────────────────────

local function OpenDoctorMenu(locName)
    isInMenu = true
    local p  = Config.Prices

    local elements = {
        {
            label = ("Лечение   $%.2f"):format(p.heal),
            value = "heal",
            desc  = "Восстановить здоровье",
        },
        {
            label = ("Выносливость   $%.2f"):format(p.stamina),
            value = "stamina",
            desc  = "Восстановить выносливость",
        },
        {
            label = ("Полное лечение   $%.2f"):format(p.full),
            value = "full",
            desc  = "Восстановить здоровье и выносливость",
        },
    }

    MenuData.Open("default", GetCurrentResourceName(), "varta_medic_menu", {
        title       = "Доктор",
        subtext     = locName,
        align       = "top-left",
        elements    = elements,
        soundOpen   = true,
        hideRadar   = true,
        divider     = true,
        fixedHeight = true,
        itemHeight  = "4vh",
    }, function(data, menu)
        menu.close(true, true, true)
        isInMenu = false

        Core.Callback.TriggerAsync("varta_medic:cb:heal", function(success)
            if success then
                ApplyHeal(data.current.value)
            end
        end, data.current.value)

    end, function(_, menu)
        menu.close(true, true)
        isInMenu = false
    end)
end

-- ─── Main thread ─────────────────────────────────────────────────────────────

CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    Wait(1000)

    -- Блипы на карте
    for _, loc in pairs(Config.Locations) do
        local blip = BlipAddForCoords(1664425300, loc.blip.x, loc.blip.y, loc.blip.z)
        SetBlipSprite(blip, joaat("blip_mp_travelling_saleswoman"), false)
        BlipAddModifier(blip, joaat("BLIP_MODIFIER_MP_COLOR_3"))
        SetBlipName(blip, loc.name)
    end

    SetupPrompt()

    while true do
        local sleep      = 1000
        local playerPos  = GetEntityCoords(PlayerPedId())

        for _, loc in pairs(Config.Locations) do
            local npcPos = vector3(loc.npc.x, loc.npc.y, loc.npc.z)
            local dist   = #(playerPos - npcPos)

            -- Спавн / деспавн NPC
            if dist < Config.NpcDistanceSpawn then
                if not loc.npcHandle then
                    loc.npcHandle = SpawnNPC(loc)
                end
            else
                if loc.npcHandle then
                    if DoesEntityExist(loc.npcHandle) then
                        DeleteEntity(loc.npcHandle)
                    end
                    loc.npcHandle = nil
                end
            end

            -- Показ подсказки и открытие меню
            if dist < Config.InteractDistance and not isInMenu then
                sleep = 0
                UiPromptSetActiveGroupThisFrame(PromptGroup, VarString(10, 'LITERAL_STRING', loc.name), 0, 0, 0, 0)

                if UiPromptHasStandardModeCompleted(Prompt, 0) then
                    Wait(200)
                    OpenDoctorMenu(loc.name)
                end
            end
        end

        Wait(sleep)
    end
end)

-- ─── Cleanup ─────────────────────────────────────────────────────────────────

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, loc in pairs(Config.Locations) do
        if loc.npcHandle and DoesEntityExist(loc.npcHandle) then
            DeleteEntity(loc.npcHandle)
            loc.npcHandle = nil
        end
    end
end)
