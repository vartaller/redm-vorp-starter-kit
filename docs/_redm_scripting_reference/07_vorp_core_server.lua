--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: СЕРВЕРНОЕ API (vorp_core, vorp_inventory)
  Проверено на практике. Источники: vorp_stores, vorp_bartenders.
═══════════════════════════════════════════════════════════════

  Всё ниже выполняется ТОЛЬКО В server.lua!
  Деньги, инвентарь, база данных — НИКОГДА на клиенте.
]]

-- ─────────────────────────────────────────────
-- 1. ПОЛУЧЕНИЕ VORP CORE (сервер)
-- ─────────────────────────────────────────────

-- Способ 1 — через event (старый, но рабочий):
local VORPcore = {}
TriggerEvent("getCore", function(core) VORPcore = core end)

-- Способ 2 — через export (vorp_stores использует):
local Core = exports.vorp_core:GetCore()

-- Оба работают. Export — более современный.

-- ─────────────────────────────────────────────
-- 2. ПОЛУЧЕНИЕ ИГРОКА И ПЕРСОНАЖА
-- ─────────────────────────────────────────────

RegisterServerEvent("myResource:doSomething")
AddEventHandler("myResource:doSomething", function(arg1, arg2)
    local src = source  -- ID игрока на сервере (number)

    -- Получить пользователя:
    local user = VORPcore.getUser(src)
    if not user then return end

    -- Получить активного персонажа:
    local character = user.getUsedCharacter   -- ⚠️ это СВОЙСТВО, не функция!
    if not character then return end           -- нет, НЕ user.getUsedCharacter()

    -- Теперь character содержит данные персонажа.
end)

-- ─────────────────────────────────────────────
-- 3. СВОЙСТВА ПЕРСОНАЖА (character.*)
-- ─────────────────────────────────────────────

--[[
  ✅ ПРЯМЫЕ СВОЙСТВА (читаем напрямую):

    character.money       — баланс долларов (number)
    character.gold        — баланс золота (number)
    character.firstname   — имя персонажа (string)
    character.lastname    — фамилия персонажа (string)

  ❌ НЕ СУЩЕСТВУЕТ:
    character.getMoney    → nil! Используй character.money
    character.getGold     → nil! Используй character.gold
]]

local money = character.money       -- ✅ правильно
local gold  = character.gold        -- ✅ правильно
-- local money = character.getMoney  -- ❌ nil!

-- ─────────────────────────────────────────────
-- 4. УПРАВЛЕНИЕ ДЕНЬГАМИ
-- ─────────────────────────────────────────────

--[[
  character.removeCurrency(type, amount)
  character.addCurrency(type, amount)

  type:
    0 = доллары (cash)
    1 = золото (gold)

  ❌ НЕ СУЩЕСТВУЕТ:
    character.removeGold(amount)     → используй character.removeCurrency(1, amount)
    character.removeMoney(amount)    → используй character.removeCurrency(0, amount)
    character.addGold(amount)        → используй character.addCurrency(1, amount)
    character.addMoney(amount)       → используй character.addCurrency(0, amount)
]]

-- Снять доллары:
character.removeCurrency(0, price)    -- ✅

-- Снять золото:
character.removeCurrency(1, price)    -- ✅

-- Добавить доллары:
character.addCurrency(0, amount)      -- ✅

-- Добавить золото:
character.addCurrency(1, amount)      -- ✅

-- ─────────────────────────────────────────────
-- 5. УВЕДОМЛЕНИЯ (notifications)
-- ─────────────────────────────────────────────

-- Уведомление-цель (по центру экрана):
VORPcore.NotifyObjective(src, "Message text", 4000)   -- 4000ms = 4 секунды

-- Уведомление справа (маленький тултип):
VORPcore.NotifyRightTip(src, "You bought a drink for $2", 4000)

-- ─────────────────────────────────────────────
-- 6. VORP INVENTORY — СЕРВЕРНЫЕ EXPORTS
-- ─────────────────────────────────────────────

local VORPInv = exports.vorp_inventory

-- Проверить, существует ли предмет в базе данных:
local itemExists = VORPInv:getItemDB(itemName)
-- Возвращает данные предмета или nil/false если не найден.
-- ВАЖНО: если предмет не зарегистрирован в items таблице БД,
-- addItem вызовет ошибку!

-- Проверить, может ли игрок взять ещё предметов:
local canCarry  = VORPInv:canCarryItems(src, quantity)   -- общий лимит инвентаря
local canCarry2 = VORPInv:canCarryItem(src, itemName, quantity)  -- лимит конкретного предмета

-- Добавить предмет:
VORPInv:addItem(src, itemName, quantity)

-- Удалить предмет:
VORPInv:subItem(src, itemName, quantity)

-- Создать оружие:
VORPInv:createWeapon(src, weaponName)

-- Проверить, может ли нести оружие:
local canCarryWep = VORPInv:canCarryWeapons(src, quantity, nil, weaponName)

-- ─────────────────────────────────────────────
-- 7. ПОЛНЫЙ ПРИМЕР: ПОКУПКА ПРЕДМЕТА
-- ─────────────────────────────────────────────

local VORPcore = {}
TriggerEvent("getCore", function(core) VORPcore = core end)

RegisterServerEvent("myResource:buyItem")
AddEventHandler("myResource:buyItem", function(itemName, price)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    if not character then return end

    -- Проверка баланса
    if character.money < price then
        VORPcore.NotifyObjective(src, "Not enough money!", 4000)
        return
    end

    -- Проверка предмета в БД
    local VORPInv = exports.vorp_inventory
    if not VORPInv:getItemDB(itemName) then
        VORPcore.NotifyObjective(src, "Item not available!", 4000)
        return
    end

    -- Проверка места в инвентаре
    if not VORPInv:canCarryItems(src, 1) or not VORPInv:canCarryItem(src, itemName, 1) then
        VORPcore.NotifyObjective(src, "Inventory full!", 4000)
        return
    end

    -- Снимаем деньги и выдаём предмет
    character.removeCurrency(0, price)
    VORPInv:addItem(src, itemName, 1)

    VORPcore.NotifyRightTip(src, "Bought " .. itemName .. " for $" .. price, 4000)
end)

--[[
═══════════════════════════════════════════════════════════════
  ЛОВУШКИ СЕРВЕРНОГО API:
═══════════════════════════════════════════════════════════════

  ❌ character.getMoney         → nil! Используй character.money
  ❌ character.getGold          → nil! Используй character.gold
  ❌ character.removeGold(n)    → nil! Используй character.removeCurrency(1, n)
  ❌ character.removeMoney(n)   → nil! Используй character.removeCurrency(0, n)
  ❌ user.getUsedCharacter()    → НЕ вызывай как функцию! Это свойство: user.getUsedCharacter

  ✅ character.money            — баланс долларов
  ✅ character.gold             — баланс золота
  ✅ character.removeCurrency(0, n)  — снять доллары
  ✅ character.removeCurrency(1, n)  — снять золото
  ✅ character.addCurrency(0, n)     — добавить доллары
  ✅ character.addCurrency(1, n)     — добавить золото
]]
