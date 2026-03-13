-- ======================================================================
-- ----------------------------------------------------------------------
-- User Class (CUSTOM)
-- ----------------------------------------------------------------------
-- Replace placeholders with your framework integration.
-- ======================================================================

---@class CustomUser : table
---@field source integer source ID
---@field data table
local User = {
    source = 0,
    data = {}
}

function User:get(source)
    self = table.copy(User)
    self.source = tonumber(source)
    -- TODO: load and store your framework player object here
    self.data = {}
    return self
end

function User:getIdentifiers()
    -- TODO: map these fields to your framework identifiers
    return {
        identifier = "unknown",
        charid = "0"
    }
end

function User:getJobFullData()
    -- TODO: return your framework job shape
    return {
        name = "unemployed",
        label = "Unemployed",
        grade = {
            level = 0,
            label = "none"
        }
    }
end

function User:getPlayerData(options)
    if not options or type(options) ~= "table" then options = { permission = "admin" } end

    -- TODO: return real values from your framework
    return {
        money = 0,
        gold = 0,
        job = self:getJobFullData(),
        identifiers = self:getIdentifiers(),
        rpName = "Unknown",
        group = "user",
        hasPermission = false -- TODO: return true if user has permission (is admin or not)
    }
end

-- ======================================================================
-- ----------------------------------------------------------------------
-- Framework Class (CUSTOM)
-- ----------------------------------------------------------------------
-- ======================================================================

---@class CustomFramework : table
---@field name string
---@field core table
---@field cachedInventories table
local CustomFramework = {
    name = "",
    core = {},
    cachedInventories = {}
}

function CustomFramework:initFramework()
    -- TODO: initialize your framework exports/dependencies
    -- Example:
    -- self.core = exports['custom-framework']:GetCore()
    -- print("CustomFramework initialized")
end

function CustomFramework:getUser(source)
    if not source or source == 0 then
        return print("[framework:getUser]: source is required!")
    end
    return User:get(source)
end

function CustomFramework:canUserBuy(source, amount, moneyType, removeIfCan)
    -- TODO: check player funds and optionally remove
    return false
end

function CustomFramework:getInventoryURL()
    -- TODO: return your inventory images URL prefix if used
    return "nui://custom-inventory/html/images/"
end

function CustomFramework:canUseItem(source, item, amount, metadata, removeIfCan)
    -- TODO: check item availability, and optionally remove
    return false
end

function CustomFramework:giveItem(source, item, quantity, metadata)
    -- TODO: give item to player
    return false
end

function CustomFramework:registerUseItem(item, closeAfterUse, callback)
    -- TODO: register usable item and invoke callback(source, { metadata = ... })
end

function CustomFramework:createOrUpdateInventory(id, name, options)
    -- TODO: Create or update inventory/stash in your framework
end

function CustomFramework:openInventory(source, id)
    -- TODO: open your framework inventory UI/container
end

function CustomFramework:removeInventory(id)
    -- TODO: remove/cleanup inventory if needed
end

function CustomFramework:addItemsToInventory(source, id, items)
    -- TODO: implement custom inventory stash logic
    -- items is a table of { metadata, amount, name, id }
end

function CustomFramework:getItemsFromInventory(id)
    -- TODO: return array of { metadata, amount, name, id }
    return {}
end

function CustomFramework:getUserInventoryItems(source)
    -- TODO: return player inventory items list
    -- return like this (list of items):
    -- {
    --   ...
    --   {
    --     id = 101,
    --     name = "water",
    --     label = "Water",
    --     type = "item",      -- "item" | "weapon"
    --     amount = 5,
    --     metadata = {},
    --     weight = 100,       -- can be nil
    --     image = "water.png",-- can be nil
    --     framework = "VORP", -- or "RSG"
    --     raw = {...}         -- original framework item object
    --   }
    --   ...
    -- }
    return {}
end

exports("Framework:custom", function()
    local instance = table.copy(CustomFramework)
    instance:initFramework()
    return instance
end)
