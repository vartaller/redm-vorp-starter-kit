--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: VORP MENU API
  Проверено на практике. Источники: vorp_stores, vorp_bartenders,
  исходный код vorp_menu/client/main.lua.
═══════════════════════════════════════════════════════════════

  ВАЖНО: vorp_menu имеет ТОЛЬКО ОДИН экспорт — GetMenuData().
  Все остальные «экспорты» (openMenu, closeAll) НЕ СУЩЕСТВУЮТ!

  ❌ exports.vorp_menu:openMenu(...)   → ОШИБКА: No such export
  ❌ exports.vorp_menu:closeAll()      → ОШИБКА: No such export
  ✅ exports.vorp_menu:GetMenuData()   → возвращает объект MenuData
]]

-- ─────────────────────────────────────────────
-- 1. ПОЛУЧЕНИЕ MenuData (один раз, вверху файла)
-- ─────────────────────────────────────────────

local MenuData = exports.vorp_menu:GetMenuData()

-- ─────────────────────────────────────────────
-- 2. ОТКРЫТИЕ МЕНЮ — MenuData.Open()
-- ─────────────────────────────────────────────

--[[
  MenuData.Open(type, resourceName, menuId, data, submitCallback, cancelCallback)

  Параметры:
    type            — 'default' (единственный тип)
    resourceName    — GetCurrentResourceName()
    menuId          — уникальная строка для этого меню (напр. 'bartender_valentine')
    data            — таблица с настройками (см. ниже)
    submitCallback  — function(data, menu) — вызывается при выборе элемента
    cancelCallback  — function(data, menu) — вызывается при нажатии «назад»
]]

-- Формирование элементов:
local elements = {}
elements[#elements + 1] = {
    label = "Kentucky Bourbon  ~g~$2",   -- текст в меню (~g~ = зелёный цвет)
    value = 1,                            -- значение, доступное в callback
}
elements[#elements + 1] = {
    label = "Cold Beer  ~g~$1",
    value = 2,
}
elements[#elements + 1] = {
    label = "~r~Leave",                   -- ~r~ = красный цвет
    value = 0,
}

-- Открытие:
MenuData.Open('default', GetCurrentResourceName(), 'my_menu_id', {
    title    = "Smithfield's Saloon",     -- заголовок меню
    subtext  = "What'll it be?",          -- подзаголовок
    align    = "top-left",                -- позиция: "top-left", "top-right"
    elements = elements,                  -- список элементов
}, function(data, menu)
    -- SUBMIT: игрок выбрал элемент
    local selectedValue = data.current.value   -- ⚠️ data.CURRENT.value, НЕ data.value!
    local selectedLabel = data.current.label

    if selectedValue == 0 then
        MenuData.CloseAll()   -- закрыть меню
    else
        -- обработка выбора
        TriggerServerEvent("myResource:buy", selectedValue)
        MenuData.CloseAll()
    end
end, function(data, menu)
    -- CANCEL: игрок нажал «назад» / ESC
    MenuData.CloseAll()
end)

-- ─────────────────────────────────────────────
-- 3. ЗАКРЫТИЕ МЕНЮ
-- ─────────────────────────────────────────────

MenuData.CloseAll()   -- закрыть все открытые меню

-- ─────────────────────────────────────────────
-- 4. ПОЛНЫЙ ПРИМЕР (из vorp_bartenders)
-- ─────────────────────────────────────────────

local menuOpen = false

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

--[[
═══════════════════════════════════════════════════════════════
  ЛОВУШКИ VORP MENU:
═══════════════════════════════════════════════════════════════

  ❌ exports.vorp_menu:openMenu({...}, cb1, cb2)
     → No such export openMenu! Используй MenuData.Open().

  ❌ exports.vorp_menu:closeAll()
     → No such export closeAll! Используй MenuData.CloseAll().

  ❌ data.value в submit callback
     → nil! Значение лежит в data.current.value.

  ❌ subtitle = "text"
     → Параметр называется subtext, не subtitle!

  ✅ ПРАВИЛЬНЫЙ ПОРЯДОК:
     1. local MenuData = exports.vorp_menu:GetMenuData()
     2. MenuData.Open('default', GetCurrentResourceName(), id, {...}, submitFn, cancelFn)
     3. В submit: data.current.value — выбранное значение
     4. MenuData.CloseAll() — закрыть

  ЦВЕТА В ТЕКСТЕ ЭЛЕМЕНТОВ:
    ~r~  — красный
    ~g~  — зелёный
    ~b~  — синий
    ~y~  — жёлтый
    ~p~  — фиолетовый
    ~o~  — оранжевый
    ~s~  — сброс цвета
]]
