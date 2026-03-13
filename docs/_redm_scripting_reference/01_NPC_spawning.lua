--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: СПАВН NPC (PED)
  Проверено на практике. Источники: vorp_stores, vorp_stables,
  juSa_static_NPCs.
═══════════════════════════════════════════════════════════════

  ВАЖНО: RedM — это НЕ GTA V / FiveM!
  Многие нативки из GTA V здесь НЕ СУЩЕСТВУЮТ.
  Ниже перечислено что работает, а что нет.
]]

-- ─────────────────────────────────────────────
-- 1. ЗАГРУЗКА МОДЕЛИ
-- ─────────────────────────────────────────────

-- Всегда проверяй модель перед загрузкой:
local model = GetHashKey("U_M_M_ValBartender_01")
-- или через backtick-синтаксис в config:
-- model = `U_M_M_ValBartender_01`

if not IsModelValid(model) then
    print("Model is invalid!")
    return
end

RequestModel(model, false)
local timeout = 0
repeat
    Wait(100)
    timeout = timeout + 100
until HasModelLoaded(model) or timeout > 10000

if not HasModelLoaded(model) then
    print("Model failed to load!")
    return
end

-- ─────────────────────────────────────────────
-- 2. СОЗДАНИЕ PED
-- ─────────────────────────────────────────────

-- CreatePed(model, x, y, z, heading, p5, p6, p7, p8)
-- vorp_stores использует:        false, false, false, false
-- juSa_static_NPCs использует:   false, true,  true,  true
-- Оба варианта работают.

local ped = CreatePed(model, x, y, z, heading, false, false, false, false)

-- ВАЖНО: ped может создаться не мгновенно. Ждём:
repeat Wait(100) until DoesEntityExist(ped)

-- ─────────────────────────────────────────────
-- 3. НАСТРОЙКА PED — ЧТО РАБОТАЕТ В RedM
-- ─────────────────────────────────────────────

-- ✅ РАБОТАЕТ в RedM:
Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- случайная одежда (SetRandomOutfitVariation)
PlaceEntityOnGroundProperly(ped)             -- правильно поставить на землю
Wait(10)                                     -- дать физике "посадить" NPC на пол
SetEntityCanBeDamaged(ped, false)            -- нельзя повредить
SetEntityInvincible(ped, true)               -- бессмертный
SetBlockingOfNonTemporaryEvents(ped, true)   -- не реагирует на события (выстрелы, пожары)
FreezeEntityPosition(ped, true)              -- не двигается с места
SetEntityVisible(ped, true, false)           -- видимый
SetEntityNoCollisionEntity(PlayerPedId(), ped, false) -- без коллизии с игроком

-- Для освобождения памяти после спавна:
SetModelAsNoLongerNeeded(model)

--[[
  ПОРЯДОК ВАЖЕН:
  1. PlaceEntityOnGroundProperly — ставим на землю
  2. Wait(10) — даём физике сработать
  3. FreezeEntityPosition — замораживаем ПОСЛЕ приземления
  Если заморозить до PlaceEntityOnGroundProperly — NPC зависнет в воздухе!
]]

-- ❌ НЕ СУЩЕСТВУЕТ в RedM (вызовет nil error, скрипт упадёт!):
-- SetPedCanBeTargetted(ped, false)     → используй SetEntityCanBeDamaged()
-- SetPedDiesWhenInjured(ped, false)    → не нужно, SetEntityInvincible() достаточно
-- SetRandomOutfitVariation(ped, true)  → вызывай через Citizen.InvokeNative(0x283978A15512B2FE, ped, true)

--[[
  ОБЩЕЕ ПРАВИЛО: если функция вызывает "attempt to call a nil value",
  значит она не существует в RedM. Ищи native hash (0x...) в рабочих
  скриптах и вызывай через Citizen.InvokeNative(hash, args...)
]]

-- ─────────────────────────────────────────────
-- 4. УДАЛЕНИЕ PED
-- ─────────────────────────────────────────────

if DoesEntityExist(ped) then
    DeleteEntity(ped)
end

--[[
═══════════════════════════════════════════════════════════════
  МОДЕЛИ БАРМЕНОВ RedM (проверены, все валидные):
═══════════════════════════════════════════════════════════════

  U_F_M_TljBartender_01        — женщина
  U_F_M_VHTBARTENDER_01        — женщина (Van Horn)
  U_M_M_NbxBartender_01        — мужчина
  U_M_M_NbxBartender_02        — мужчина
  U_M_M_RhdBartender_01        — мужчина (Rhodes)
  U_M_M_TumBartender_01        — мужчина (Tumbleweed)
  U_M_M_ValBartender_01        — мужчина (Valentine)
  U_M_O_ARMBARTENDER_01        — мужчина старый (Armadillo)
  U_M_O_BlWBartender_01        — мужчина старый (Blackwater)
  U_M_O_ValBartender_01        — мужчина старый (Valentine, Keane's)

  Модели продавцов (из vorp_stores):
  U_M_M_NbxGeneralStoreOwner_01
  S_M_M_UNIBUTCHERS_01
  u_m_m_sdtrapper_01

  Модель стабльмена (из vorp_stables):
  U_M_M_BwmStablehand_01
]]
