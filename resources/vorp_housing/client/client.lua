local LIB <const>     = Import({ "/config", 'blips', 'prompts' })
local CONFIG <const>  = LIB.CONFIG --[[@as vorp_housing_config]]
local Blips <const>   = LIB.Blips --[[@as MAP]]
local Prompts <const> = LIB.Prompts --[[@as PROMPTS]]
local CHARID       = 0
local ownedHouses  = {}  -- [houseIndex] = true
local Core <const>    = exports.vorp_core:GetCore()

local availableHouses = {}
local availableBlips  = {} -- houseIndex -> blip handle
local buyPromptHandle = nil


local function removeAvailableBlip(houseIndex)
    if availableBlips[houseIndex] then
        RemoveBlip(availableBlips[houseIndex])
        availableBlips[houseIndex] = nil
    end
end


local function removeBuyPrompt()
    if buyPromptHandle then
        UiPromptDelete(buyPromptHandle)
        buyPromptHandle = nil
    end
end

local function registerLocations(houseIndex)
    local values <const> = CONFIG.HOUSES[houseIndex]
    local locations <const> = {}
    for _, storage in ipairs(values.STORAGES) do
        table.insert(locations, {
            coords   = storage.LOCATION,
            label    = storage.LABEL,
            distance = 2.0,
        })
    end

    local data = {
        sleep     = 800,
        locations = locations,
        prompts   = {
            {
                type  = "Press",
                key   = `INPUT_SHOP_SELL`, -- R
                label = CONFIG.TRANSLATION.press,
                mode  = 'Standard',
            },
        }
    }

    Prompts:Register(data, function(_, index, _)
        local location <const> = CONFIG.HOUSES[houseIndex]
        if not location then return end
        if CHARID == 0 then return end

        local storage <const> = location.STORAGES[index]
        if not storage then return end

        TriggerServerEvent("vorp_housing:Server:OpenStorage", houseIndex, index)
    end, true)
end


RegisterNetEvent("vorp_housing:Client:RegisterHouse", function(index, charId)
    CHARID = charId

    local value <const> = CONFIG.HOUSES[index]
    if not value then return end

    if ownedHouses[index] then return end
    ownedHouses[index] = true

    if value.BLIP.ENABLE then
        Blips:Create('coords', {
            Pos   = value.POSITION,
            Blip  = value.BLIP.STYLE,
            Options = {
                sprite = value.BLIP.SPRITE,
                name   = value.BLIP.NAME,
            },
        })
    end

    -- Remove owned house from buy list and its for-sale blip
    removeAvailableBlip(index)
    for i, v in ipairs(availableHouses) do
        if v == index then
            table.remove(availableHouses, i)
            break
        end
    end

    Wait(5000)
    registerLocations(index)
end)


RegisterNetEvent("vorp_housing:Client:SetAvailableHouses", function(houses)
    print(("[vorp_housing] [CL] Received %d available houses"):format(#houses))
    -- Clear old for-sale blips
    for _, handle in pairs(availableBlips) do
        RemoveBlip(handle)
    end
    availableBlips = {}

    availableHouses = houses

    -- Create blips for all available houses (delayed to ensure world is loaded)
    local housesToBlip <const> = houses
    CreateThread(function()
        Wait(5000)
        for _, houseIndex in ipairs(housesToBlip) do
            local house <const> = CONFIG.HOUSES[houseIndex]
            if house and not availableBlips[houseIndex] then
                local price <const> = CONFIG.HOUSE_PRICES[houseIndex] or 0
                local blip = Blips:Create('coords', {
                    Pos   = house.POSITION,
                    Blip  = `BLIP_STYLE_PROPERTY_OWNER`,
                    Options = {
                        sprite = `blip_mp_base`,
                        name   = CONFIG.TRANSLATION.buy .. " - $" .. price,
                    },
                })
                availableBlips[houseIndex] = blip:GetHandle()
            end
        end
        print(("[vorp_housing] [CL] Created blips for %d available houses"):format(#housesToBlip))
    end)
end)

RegisterNetEvent("vorp_housing:Client:HouseBought", function()
    print("[vorp_housing] [CL] House purchase confirmed by server")
    removeBuyPrompt()
    Core.NotifyObjective(CONFIG.TRANSLATION.bought, 5000)
end)

RegisterNetEvent("vorp_housing:Client:Notify", function(msg, duration)
    Core.NotifyObjective(msg, duration)
end)


-- Buy prompt loop: shows prompt when near an unowned house
CreateThread(function()
    while true do
        local sleep = 1000

        if #availableHouses > 0 then
            local pos <const> = GetEntityCoords(PlayerPedId())
            local nearIndex   = nil
            local nearDist    = nil

            for _, houseIndex in ipairs(availableHouses) do
                local house = CONFIG.HOUSES[houseIndex]
                if house then
                    local dist = #(pos - house.POSITION)
                    if dist < 10.0 then
                        nearIndex = houseIndex
                        nearDist  = dist
                        break
                    end
                end
            end

            if nearIndex then
                sleep = 0
                local price <const> = CONFIG.HOUSE_PRICES[nearIndex] or 0

                if not buyPromptHandle then
                    print(("[vorp_housing] [CL] Near house #%d ($%.1f), dist=%.1f, showing buy prompt"):format(nearIndex, price, nearDist))
                    buyPromptHandle = UiPromptRegisterBegin()
                    UiPromptSetControlAction(buyPromptHandle, `INPUT_SHOP_SELL`)
                    local label <const> = CreateVarString(10, 'LITERAL_STRING', CONFIG.TRANSLATION.buy .. " - $" .. price)
                    UiPromptSetText(buyPromptHandle, label)
                    UiPromptSetHoldMode(buyPromptHandle, 2000)
                    UiPromptSetEnabled(buyPromptHandle, true)
                    UiPromptSetVisible(buyPromptHandle, true)
                    UiPromptRegisterEnd(buyPromptHandle)
                    print(("[vorp_housing] [CL] Prompt registered, handle=%s"):format(tostring(buyPromptHandle)))
                end

                if UiPromptHasHoldModeCompleted(buyPromptHandle) then
                    print(("[vorp_housing] [CL] Buy hold completed for house #%d"):format(nearIndex))
                    TriggerServerEvent("vorp_housing:Server:BuyHouse", nearIndex)
                    removeBuyPrompt()
                    Wait(2000) -- prevent spam
                end
            else
                removeBuyPrompt()
            end
        end

        Wait(sleep)
    end
end)


-- Dev mode
if CONFIG.DEV_MODE then
    local blips <const> = {}

    RegisterNetEvent("vorp_housing:Client:ShowHouses", function()
        local houses <const> = CONFIG.HOUSES

        for _, blip in ipairs(blips) do
            RemoveBlip(blip)
        end
        table.wipe(blips)

        for index, house in ipairs(houses) do
            local blip = Blips:Create('coords', {
                Pos   = house.POSITION,
                Blip  = `BLIP_STYLE_PROPERTY_OWNER`,
                Options = {
                    sprite = `blip_mp_base`,
                    name   = "House index: " .. index,
                },
            })
            table.insert(blips, blip:GetHandle())
        end
    end)
end
