local Core <const> = exports.vorp_core:GetCore()

Core.Callback.Register("varta_medic:cb:heal", function(source, cb, healType)
    local user = Core.getUser(source)
    if not user then return cb(false) end

    local price = Config.Prices[healType]
    if not price then return cb(false) end

    local Character = user.getUsedCharacter

    if Character.money < price then
        Core.NotifyObjective(source, ("Недостаточно денег. Нужно $%.2f"):format(price), 4000)
        return cb(false)
    end

    Character.removeCurrency(0, price)
    Core.NotifyRightTip(source, ("Оплачено: $%.2f"):format(price), 3000)
    return cb(true)
end)
