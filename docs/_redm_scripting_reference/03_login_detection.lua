--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: ДЕТЕКЦИЯ ЛОГИНА ИГРОКА
  Проверено на практике. Источники: vorp_stores, vorp_stables,
  juSa_static_NPCs.
═══════════════════════════════════════════════════════════════

  ПРОБЛЕМА:
  client.lua выполняется сразу при загрузке ресурса, но игрок ещё
  не выбрал персонажа. Нельзя спавнить NPC, пока игрок не в мире.
  Нужно дождаться "логина".

  ЕСТЬ НЕСКОЛЬКО СПОСОБОВ. Не все работают на всех версиях vorp_core.
]]

-- ─────────────────────────────────────────────
-- СПОСОБ 1: vorp:SelectedCharacter (САМЫЙ НАДЁЖНЫЙ)
-- Используют: juSa_static_NPCs, vorp_stables
-- ─────────────────────────────────────────────

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    -- charid — ID выбранного персонажа
    print("Player selected character: " .. tostring(charid))
    -- Здесь спавним NPC, создаём блипы и т.д.
end)

-- ─────────────────────────────────────────────
-- СПОСОБ 2: LocalPlayer.state.IsInSession (vorp_stores)
-- ─────────────────────────────────────────────

CreateThread(function()
    repeat Wait(2000) until LocalPlayer.state.IsInSession
    -- Игрок в сессии, можно работать
end)

-- ─────────────────────────────────────────────
-- СПОСОБ 3: LocalPlayer.state.isLoggedIn
-- ⚠️  НЕ РАБОТАЕТ на некоторых версиях vorp_core!
-- ─────────────────────────────────────────────

-- НЕ РЕКОМЕНДУЕТСЯ:
-- while not LocalPlayer.state.isLoggedIn do Wait(1000) end
-- Может зависнуть навсегда!

-- ─────────────────────────────────────────────
-- СПОСОБ 4: Fallback — проверка существования игрока
-- ─────────────────────────────────────────────

-- Используется как запасной вариант, если событие не сработало:
CreateThread(function()
    Wait(30000)  -- ждём 30 секунд
    local ped = PlayerPedId()
    if ped and ped ~= 0 and DoesEntityExist(ped) then
        -- Игрок есть в мире, можно спавнить
    end
end)

--[[
═══════════════════════════════════════════════════════════════
  РЕКОМЕНДУЕМЫЙ ПАТТЕРН:
  Событие vorp:SelectedCharacter + fallback через 30 сек.
  Флаг hasSpawned защищает от двойного выполнения.
═══════════════════════════════════════════════════════════════
]]

local hasSpawned = false

local function init()
    if hasSpawned then return end
    hasSpawned = true
    Wait(5000) -- небольшая пауза для стабильности
    -- ... спавн NPC, блипы, промпты ...
end

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function()
    CreateThread(init)
end)

CreateThread(function()
    Wait(30000)
    if not hasSpawned then
        local ped = PlayerPedId()
        if ped and ped ~= 0 and DoesEntityExist(ped) then
            init()
        end
    end
end)
