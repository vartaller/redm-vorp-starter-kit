Config = {}

-- Interaction distance (in game units)
Config.InteractDistance = 2.4

-- Blip settings
Config.ShowBlips = true
Config.BlipSprite = 1879260108

-- Currency type: 0 = dollars, 1 = gold
Config.CurrencyType = 0

-- NPC model (male bartender)
Config.PedModel = `U_M_M_BARTENDER_01`

-- Menu open key (G)
Config.MenuKey = 0x760A9C6F

--[[
    Saloon configs.
    Each saloon has:
      - name       : display name
      - bartender  : xyz coords where the NPC will stand
      - heading    : direction the NPC faces (0-360)
      - drinks     : table of 3 drinks available at this bar
        - label    : display name in menu
        - item     : internal item name in vorp_inventory DB
        - price    : cost in dollars (or gold if CurrencyType = 1)
        - desc     : short description shown in menu
]]

Config.Saloons = {

    -- Valentine
    Smithfields = {
        name     = "Smithfield's Saloon",
        bartender = { x = -313.90, y = 807.62, z = 118.98 },
        heading  = 280.43,
        model    = `U_M_M_ValBartender_01`,
        drinks   = {
            { label = "Kentucky Bourbon",  item = "whiskey",     price = 2,  desc = "Smooth bourbon straight from Kentucky." },
            { label = "Cold Beer",         item = "beer",        price = 1,  desc = "A refreshing cold one." },
            { label = "Moonshine",         item = "moonshine",   price = 3,  desc = "Strong homemade moonshine." },
        },
    },

    Keanes = {
        name     = "Keane's Saloon",
        bartender = { x = -239.12, y = 770.71, z = 118.10 },
        heading  = 99.72,
        model    = `U_M_O_ValBartender_01`,
        drinks   = {
            { label = "Rye Whiskey",       item = "whiskey",     price = 2,  desc = "Classic rye with a sharp bite." },
            { label = "Red Wine",          item = "wine",        price = 3,  desc = "A fine bottle from the east." },
            { label = "Gin",               item = "gin",         price = 2,  desc = "Dry gin with a floral note." },
        },
    },

    -- Annesburg
    Emerald = {
        name     = "Emerald Ranch Saloon",
        bartender = { x = 1451.32, y = 371.88, z = 89.89 },
        heading  = 92.78,
        model    = `U_M_M_NbxBartender_01`,
        drinks   = {
            { label = "Tennessee Whiskey", item = "whiskey",     price = 2,  desc = "Bold Tennessee whiskey." },
            { label = "Cold Beer",         item = "beer",        price = 1,  desc = "A cold mug of beer." },
            { label = "Apple Cider",       item = "cider",       price = 2,  desc = "Sweet local apple cider." },
        },
    },

    -- Saint Denis
    Bastille = {
        name     = "Bastille Saloon",
        bartender = { x = 2640.14, y = -1226.39, z = 53.38 },
        heading  = 95.43,
        model    = `U_M_M_NbxBartender_02`,
        drinks   = {
            { label = "French Brandy",     item = "brandy",      price = 4,  desc = "Imported brandy from France." },
            { label = "Absinthe",          item = "absinthe",    price = 5,  desc = "The green fairy. Handle with care." },
            { label = "Red Wine",          item = "wine",        price = 3,  desc = "A Bordeaux-style red." },
        },
    },

    Doyles = {
        name     = "Doyle's Tavern",
        bartender = { x = 2792.72, y = -1167.82, z = 47.93 },
        heading  = 235.02,
        model    = `U_F_M_TljBartender_01`,
        drinks   = {
            { label = "Irish Whiskey",     item = "whiskey",     price = 2,  desc = "Straight from the old country." },
            { label = "Stout Beer",        item = "beer",        price = 1,  desc = "Dark and heavy stout." },
            { label = "Moonshine",         item = "moonshine",   price = 3,  desc = "Local moonshine, potent stuff." },
        },
    },

    -- Rhodes
    Parlour = {
        name     = "The Parlour",
        bartender = { x = 1338.82, y = -1374.34, z = 80.48 },
        heading  = 272.72,
        model    = `U_M_M_RhdBartender_01`,
        drinks   = {
            { label = "Southern Bourbon",  item = "whiskey",     price = 2,  desc = "A true southern gentleman's drink." },
            { label = "Peach Wine",        item = "wine",        price = 3,  desc = "Local peach wine, sweet and light." },
            { label = "Cold Beer",         item = "beer",        price = 1,  desc = "Always cold at The Parlour." },
        },
    },

    -- Van Horn
    OldLight = {
        name     = "Old Light Saloon",
        bartender = { x = 2947.75, y = 528.56, z = 45.34 },
        heading  = 188.91,
        model    = `U_F_M_VHTBARTENDER_01`,
        drinks   = {
            { label = "Cheap Whiskey",     item = "whiskey",     price = 1,  desc = "Rough and cheap. It'll do." },
            { label = "Rum",               item = "rum",         price = 2,  desc = "Dark rum, smells like the sea." },
            { label = "Moonshine",         item = "moonshine",   price = 2,  desc = "Strong enough to clean a wound." },
        },
    },

    -- Blackwater
    Blackwater = {
        name     = "Blackwater Saloon",
        bartender = { x = -818.34, y = -1318.76, z = 43.68 },
        heading  = 259.89,
        model    = `U_M_O_BlWBartender_01`,
        drinks   = {
            { label = "Scotch Whisky",     item = "whiskey",     price = 3,  desc = "Imported Scotch, smooth and peaty." },
            { label = "Gin & Bitters",     item = "gin",         price = 3,  desc = "Gin with aromatic bitters." },
            { label = "Champagne",         item = "champagne",   price = 6,  desc = "Celebration in a glass." },
        },
    },

    -- Armadillo
    Armadillo = {
        name     = "Armadillo Saloon",
        bartender = { x = -3699.58, y = -2595.28, z = -13.32 },
        heading  = 89.49,
        model    = `U_M_O_ARMBARTENDER_01`,
        drinks   = {
            { label = "Tequila",           item = "tequila",     price = 2,  desc = "Desert spirit, burns going down." },
            { label = "Mezcal",            item = "mezcal",      price = 3,  desc = "Smoky mezcal from the south." },
            { label = "Cold Beer",         item = "beer",        price = 1,  desc = "Cold beer in the desert heat." },
        },
    },

    -- Tumbleweed
    Tumbleweed = {
        name     = "Tumbleweed Saloon",
        bartender = { x = -5517.85, y = -2905.66, z = -1.75 },
        heading  = 211.80,
        model    = `U_M_M_TumBartender_01`,
        drinks   = {
            { label = "Frontier Whiskey",  item = "whiskey",     price = 1,  desc = "Strong frontier whiskey." },
            { label = "Tequila",           item = "tequila",     price = 2,  desc = "Aged tequila from across the border." },
            { label = "Moonshine",         item = "moonshine",   price = 2,  desc = "Homemade desert moonshine." },
        },
    },
}
