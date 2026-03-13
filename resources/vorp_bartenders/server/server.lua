local VORPcore = {}
TriggerEvent("getCore", function(core) VORPcore = core end)

RegisterServerEvent("vorp_bartenders:buyDrink", function(saloonKey, drinkIdx)
    local src = source

    local saloon = Config.Saloons[saloonKey]
    if not saloon then return end

    local drink = saloon.drinks[drinkIdx]
    if not drink then return end

    local user      = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    if not character then return end

    local price    = drink.price
    local currType = Config.CurrencyType

    -- Check if player has enough money
    local balance = character.money
    if currType == 1 then
        balance = character.gold
    end

    if balance < price then
        VORPcore.NotifyObjective(src, "You don't have enough money!", 4000)
        return
    end

    -- Check inventory space
    local VORPInv = exports.vorp_inventory
    local itemExists = VORPInv:getItemDB(drink.item)

    if not itemExists then
        VORPcore.NotifyObjective(src, "Sorry, we're out of " .. drink.label .. ".", 4000)
        print("[vorp_bartenders] WARNING: item '" .. drink.item .. "' not found in database!")
        return
    end

    local canCarry  = VORPInv:canCarryItems(src, 1)
    local canCarry2 = VORPInv:canCarryItem(src, drink.item, 1)

    if not canCarry or not canCarry2 then
        VORPcore.NotifyObjective(src, "Your inventory is full!", 4000)
        return
    end

    -- Deduct money
    if currType == 1 then
        character.removeCurrency(1, price)
    else
        character.removeCurrency(0, price)
    end

    -- Give drink item
    VORPInv:addItem(src, drink.item, 1)

    VORPcore.NotifyRightTip(src, "You bought a " .. drink.label .. " for $" .. price, 4000)
end)
