local Core <const>      = exports.vorp_core:GetCore()
local LIB <const>       = Import "/config"
local CONFIG <const>    = LIB.CONFIG --[[@as vorp_housing_config]]
local Inventory <const> = exports.vorp_inventory


local function registerStorages(houseIndex)
    local house <const> = CONFIG.HOUSES[houseIndex]
    for _, storage in ipairs(house.STORAGES) do
        local prefix <const> = "house_" .. storage.ID
        if not Inventory:isCustomInventoryRegistered(prefix) then
            Inventory:registerInventory({
                id                  = prefix,
                name                = storage.LABEL,
                limit               = storage.MAX_SLOTS,
                acceptWeapons       = storage.WEAPONS,
                shared              = storage.SHARED,
                ignoreItemStackLimit = true,
                whitelistItems      = false,
                UsePermissions      = false,
                UseBlackList        = #storage.BLACKLISTED_ITEMS > 0,
                whitelistWeapons    = false,
                webhook             = ""
            })
            if #storage.BLACKLISTED_ITEMS > 0 then
                for _, item in ipairs(storage.BLACKLISTED_ITEMS) do
                    Inventory:blackListCustomAny(prefix, item)
                end
            end
        end
    end
end

local function registerHouseForPlayer(source, houseIndex, charId)
    local house <const> = CONFIG.HOUSES[houseIndex]
    if not house then return end

    registerStorages(houseIndex)

    SetTimeout(5000, function()
        for _, door in ipairs(house.DOORS) do
            exports.vorp_doorlocks:updateDoorPermission(source, door, true)
        end
        TriggerClientEvent("vorp_housing:Client:RegisterHouse", source, houseIndex, charId)
    end)
end


AddEventHandler("vorp:SelectedCharacter", function(source, character)
    local _source <const> = source
    local charId <const>  = character.charIdentifier
    print(("[vorp_housing] [SV] Character selected: charId=%d source=%d"):format(charId, _source))

    -- Load ALL owned houses from DB
    MySQL.query('SELECT id FROM housing WHERE charidentifier = ?', { charId }, function(owned)
        if owned and #owned > 0 then
            for _, row in ipairs(owned) do
                local houseIndex = tonumber(row.id)
                if houseIndex then
                    print(("[vorp_housing] [SV] charId=%d owns house #%d, registering..."):format(charId, houseIndex))
                    registerHouseForPlayer(_source, houseIndex, charId)
                end
            end
        else
            print(("[vorp_housing] [SV] charId=%d has no house"):format(charId))
        end
    end)

    -- Send list of unowned houses to client
    MySQL.query('SELECT id FROM housing', {}, function(allOwned)
        local ownedMap <const> = {}
        if allOwned then
            for _, row in ipairs(allOwned) do
                ownedMap[row.id] = true
            end
        end
        local available <const> = {}
        for i = 1, #CONFIG.HOUSES do
            if not ownedMap[i] then
                table.insert(available, i)
            end
        end
        print(("[vorp_housing] [SV] Sending %d available houses to source=%d"):format(#available, _source))
        TriggerClientEvent("vorp_housing:Client:SetAvailableHouses", _source, available)
    end)
end)


RegisterServerEvent("vorp_housing:Server:BuyHouse", function(houseIndex)
    local _source <const>   = source
    local user <const>      = Core.getUser(_source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local charId <const>    = character.charIdentifier
    local house <const>     = CONFIG.HOUSES[houseIndex]
    if not house then return end

    print(("[vorp_housing] [SV] BuyHouse request: charId=%d houseIndex=%d"):format(charId, houseIndex))

    -- Check if player already owns a house
    MySQL.query('SELECT id FROM housing WHERE charidentifier = ?', { charId }, function(r1)
        if r1 and r1[1] then
            print(("[vorp_housing] [SV] charId=%d already owns a house"):format(charId))
            TriggerClientEvent("vorp_housing:Client:Notify", _source, CONFIG.TRANSLATION.already_owns, 5000)
            return
        end

        -- Check if house is already owned by someone else
        MySQL.query('SELECT id FROM housing WHERE id = ?', { houseIndex }, function(r2)
            if r2 and r2[1] then
                print(("[vorp_housing] [SV] House #%d already owned by someone else"):format(houseIndex))
                TriggerClientEvent("vorp_housing:Client:Notify", _source, CONFIG.TRANSLATION.already_owned, 5000)
                return
            end

            local price <const> = CONFIG.HOUSE_PRICES[houseIndex] or 0
            print(("[vorp_housing] [SV] charId=%d money=%.1f gold=%.1f needs=%.1f"):format(charId, character.money, character.gold, price))
            if character.money < price then
                print(("[vorp_housing] [SV] charId=%d not enough money (has %.1f, needs %.1f)"):format(charId, character.money, price))
                TriggerClientEvent("vorp_housing:Client:Notify", _source, CONFIG.TRANSLATION.no_money, 5000)
                return
            end

            print(("[vorp_housing] [SV] charId=%d buying house #%d for $%.1f"):format(charId, houseIndex, price))
            character.removeCurrency(0, price)

            local identifier <const> = GetPlayerIdentifierByType(tostring(_source), 'license') or ''
            MySQL.insert(
                'INSERT INTO housing (id, identifier, charidentifier, open) VALUES (?, ?, ?, 0)',
                { houseIndex, identifier, charId },
                function()
                    print(("[vorp_housing] [SV] House #%d saved to DB for charId=%d"):format(houseIndex, charId))
                    registerHouseForPlayer(_source, houseIndex, charId)
                    TriggerClientEvent("vorp_housing:Client:HouseBought", _source, houseIndex)
                end
            )
        end)
    end)
end)


RegisterServerEvent("vorp_housing:Server:OpenStorage", function(index, storageIndex)
    local _source <const>   = source
    local user <const>      = Core.getUser(_source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local charId <const>    = character.charIdentifier
    local house <const>     = CONFIG.HOUSES[index]
    if not house then return print("House not found") end

    MySQL.query('SELECT id FROM housing WHERE id = ? AND charidentifier = ?', { index, charId }, function(result)
        if not result or not result[1] then
            return print(CONFIG.TRANSLATION.not_owner)
        end

        local pedCoords <const> = GetEntityCoords(GetPlayerPed(_source))
        if #(pedCoords - house.POSITION) > 10.0 then return print("Player is not close to the house") end

        local storage <const> = house.STORAGES[storageIndex]
        if not storage then return print("Storage not found") end

        if #(pedCoords - storage.LOCATION) > 3.0 then return print("Player is not close to this storage") end

        local prefix <const> = "house_" .. storage.ID
        if not Inventory:isCustomInventoryRegistered(prefix) then return print("Storage not registered") end

        Inventory:openInventory(_source, prefix)
    end)
end)


if CONFIG.DEV_MODE then
    RegisterCommand(CONFIG.COMMAND, function(source)
        local user <const> = Core.getUser(source)
        if not user then return end
        local group <const> = user.getGroup
        if group ~= "admin" then
            TriggerClientEvent("vorp_housing:Client:Notify", source, CONFIG.TRANSLATION.not_admin, 5000)
            return
        end
        TriggerClientEvent("vorp_housing:Client:ShowHouses", source)
    end, false)
end
