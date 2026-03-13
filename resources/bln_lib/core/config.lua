Config = {}

Config.debug = false
Config.isRTL = false

-----------------------------------------
-- Framework Selection
-----------------------------------------
-- If you are using a custom framework, you must set it to 'CUSTOM'.
Config.framework = false -- 'RSG', 'VORP', 'CUSTOM' (false to auto detect)

-----------------------------------------
-- Money Type Configuration
----------------------
-- Map moneyType index to framework-specific currency names
-- moneyType 0 = cash/money (primary currency, usually not changed)
-- moneyType 1 = secondary currency (gold, doge, coin, etc.)
-----------------------------------------
Config.moneyTypes = {
    RSG = {
        [0] = 'cash',    -- Primary currency
        [1] = 'gold'     -- Secondary currency (customize to 'doge', 'coin' etc.)
    },
    VORP = {
        [0] = 'money',   
        [1] = 'gold'    
    },
}