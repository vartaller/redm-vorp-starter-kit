--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: БЛИПЫ И ПРОМПТЫ
  Проверено на практике. Источники: vorp_stores, vorp_stables.
═══════════════════════════════════════════════════════════════
]]

-- ─────────────────────────────────────────────
-- 1. БЛИПЫ НА КАРТЕ
-- ─────────────────────────────────────────────

-- ✅ РАБОТАЕТ в RedM (нативная функция):
local blip = BlipAddForCoords(1664425300, x, y, z)
SetBlipSprite(blip, spriteHash, false)
SetBlipName(blip, "My Blip Name")

-- Изменение цвета блипа (из vorp_stores):
BlipAddModifier(blip, joaat("BLIP_MODIFIER_MP_COLOR_32"))  -- зелёный/активный
BlipAddModifier(blip, joaat("BLIP_MODIFIER_MP_COLOR_2"))   -- серый/закрытый

-- Удаление:
RemoveBlip(blip)

-- ❌ НЕ РАБОТАЕТ:
-- Blip.AddForCoords(x, y, z)      → это от какой-то библиотеки, не нативка
-- Blip.SetName(blip, name)        → используй SetBlipName
-- SetBlipScale(blip, 0.5)         → может не работать, зависит от версии

--[[
  SPRITE ХЭШИ (проверенные):
    1475879922   — иконка магазина (general store)
    -1406874050  — иконка мясника (butcher)
    3442726182   — иконка рыбалки (fishing)
    joaat("blip_saloon") — салун (не проверено, использовать с осторожностью)

  Первый аргумент BlipAddForCoords (1664425300) — это тип блипа.
  Всегда используй 1664425300 для координатных блипов.
]]

-- ─────────────────────────────────────────────
-- 2. ПРОМПТЫ (подсказки взаимодействия)
-- ─────────────────────────────────────────────

--[[
  RedM использует систему UiPrompt — это НЕ то же самое, что в GTA V.
  Нельзя использовать BeginTextCommandDisplayHelp — это GTA V стиль.
]]

-- Регистрация промпта (один раз при инициализации):
local PromptGroup = GetRandomIntInRange(0, 0xffffff)

local prompt = UiPromptRegisterBegin()
UiPromptSetControlAction(prompt, 0x760A9C6F)  -- кнопка G
local label = VarString(10, "LITERAL_STRING", "Open Menu")
UiPromptSetText(prompt, label)
UiPromptSetEnabled(prompt, true)
UiPromptSetVisible(prompt, true)
UiPromptSetStandardMode(prompt, true)          -- обычное нажатие
-- UiPromptSetHoldMode(prompt, 1000)           -- или удержание 1 сек (vorp_stables)
UiPromptSetGroup(prompt, PromptGroup, 0)
UiPromptRegisterEnd(prompt)

-- Показ промпта каждый кадр (в game loop, Wait(0)):
local groupName = VarString(10, "LITERAL_STRING", "Bartender Name")
UiPromptSetActiveGroupThisFrame(PromptGroup, groupName, 0, 0, 0, 0)

-- Проверка нажатия:
if UiPromptHasStandardModeCompleted(prompt, 0) then
    -- игрок нажал кнопку
end

-- Для удержания (hold mode):
-- if UiPromptHasHoldModeCompleted(prompt) then ...

-- Включить/выключить:
UiPromptSetEnabled(prompt, true)   -- включить
UiPromptSetEnabled(prompt, false)  -- выключить

-- Удаление при остановке ресурса:
UiPromptDelete(prompt)

--[[
  КОДЫ КЛАВИШ (Config.MenuKey):
    0x760A9C6F  — G
    0xCEFD9220  — E
    0xF3830D8E  — ENTER

  Полный список: https://github.com/femga/rdr3_discoveries
]]
