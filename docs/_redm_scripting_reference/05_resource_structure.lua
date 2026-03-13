--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: СТРУКТУРА РЕСУРСА
  Проверено на практике.
═══════════════════════════════════════════════════════════════
]]

-- ─────────────────────────────────────────────
-- 1. FXMANIFEST.LUA — минимальный рабочий шаблон
-- ─────────────────────────────────────────────

--[[
fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name        'my_resource'
description 'Description'
version     '1.0.0'
author      'author'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
}
]]

-- ─────────────────────────────────────────────
-- 2. СТРУКТУРА ПАПОК
-- ─────────────────────────────────────────────

--[[
my_resource/
├── fxmanifest.lua          -- обязательно
├── config.lua              -- shared (доступен и клиенту и серверу)
├── client/
│   └── client.lua          -- выполняется на ПК игрока
└── server/
    └── server.lua          -- выполняется на сервере
]]

-- ─────────────────────────────────────────────
-- 3. SHARED vs CLIENT vs SERVER
-- ─────────────────────────────────────────────

--[[
  shared_scripts  → загружается И на клиенте, И на сервере.
                    Идеально для конфигов (Config = {}).

  client_scripts  → только на ПК игрока.
                    NPC, блипы, промпты, UI, меню.

  server_scripts  → только на сервере.
                    Деньги, инвентарь, база данных, безопасность.

  ВАЖНО: client.lua выполняется У КАЖДОГО ИГРОКА ОТДЕЛЬНО.
  Каждый видит своих NPC. Сервер НЕ спавнит NPC.
]]

-- ─────────────────────────────────────────────
-- 4. ПОЛУЧЕНИЕ VORP CORE
-- ─────────────────────────────────────────────

-- Старый способ (через event):
local VORPcore = {}
TriggerEvent("getCore", function(core) VORPcore = core end)

-- Новый способ (через export, vorp_stores использует):
local Core = exports.vorp_core:GetCore()

-- Оба работают. Export — более современный.

-- ─────────────────────────────────────────────
-- 5. ПОЛУЧЕНИЕ VORP MENU (ТОЛЬКО КЛИЕНТ)
-- ─────────────────────────────────────────────

-- ❌ НЕ СУЩЕСТВУЕТ:
-- exports.vorp_menu:openMenu(...)   → такого экспорта НЕТ!
-- exports.vorp_menu:closeAll()      → такого экспорта НЕТ!

-- ✅ ПРАВИЛЬНЫЙ способ (единственный экспорт — GetMenuData):
local MenuData = exports.vorp_menu:GetMenuData()
MenuData.Open('default', GetCurrentResourceName(), 'menuId', {
    title    = "Title",
    subtext  = "Subtitle",
    align    = "top-left",
    elements = elements,
}, submitCallback, cancelCallback)
MenuData.CloseAll()

-- Подробности: см. 06_vorp_menu.lua

-- ─────────────────────────────────────────────
-- 6. ОЧИСТКА ПРИ ОСТАНОВКЕ РЕСУРСА
-- ─────────────────────────────────────────────

-- ОБЯЗАТЕЛЬНО! Иначе NPC/блипы останутся при рестарте ресурса.
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end

    -- Удалить всех NPC
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end

    -- Удалить блипы
    for _, blip in ipairs(blipHandles) do
        RemoveBlip(blip)
    end

    -- Удалить промпты
    if myPrompt then
        UiPromptDelete(myPrompt)
    end

    -- Закрыть меню
    -- MenuData.CloseAll()
end)

-- ─────────────────────────────────────────────
-- 7. КЛИЕНТ ↔ СЕРВЕР КОММУНИКАЦИЯ
-- ─────────────────────────────────────────────

-- Клиент → Сервер:
TriggerServerEvent("myResource:doSomething", arg1, arg2)

-- Сервер (принимает):
RegisterNetEvent("myResource:doSomething")
AddEventHandler("myResource:doSomething", function(arg1, arg2)
    local _source = source  -- ID игрока на сервере
    -- ... обработка ...
end)

-- Сервер → Клиент:
TriggerClientEvent("myResource:result", _source, data)

-- Клиент (принимает):
RegisterNetEvent("myResource:result")
AddEventHandler("myResource:result", function(data)
    -- ... обработка ...
end)

--[[
  БЕЗОПАСНОСТЬ:
  - Деньги, инвентарь — ТОЛЬКО на сервере!
  - Клиент отправляет запрос, сервер проверяет и выполняет.
  - Никогда не доверяй данным от клиента.
]]
