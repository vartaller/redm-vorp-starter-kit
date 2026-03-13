--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК ПО СОЗДАНИЮ СКРИПТОВ
═══════════════════════════════════════════════════════════════

  Этот справочник собирается по мере создания новых скриптов.
  Каждый файл — одна тема, проверенная на практике.

  СОДЕРЖАНИЕ:
  ───────────────────────────────────────────────
  01_NPC_spawning.lua          — спавн NPC, настройка, модели
  02_blips_and_prompts.lua     — блипы на карте, промпты (подсказки)
  03_login_detection.lua       — определение логина игрока
  04_proximity_interaction.lua — проверка дистанции, зоны
  05_resource_structure.lua    — структура ресурса, fxmanifest,
                                 client/server, события
  06_vorp_menu.lua             — vorp_menu API (MenuData.Open, CloseAll)
  07_vorp_core_server.lua      — серверное API: деньги, инвентарь,
                                 уведомления, покупка предметов

  ИСТОЧНИКИ (рабочие скрипты, проверено):
  ───────────────────────────────────────────────
  vorp_stores      — магазины с NPC, меню, промптами
  vorp_stables     — конюшни с NPC, UI
  juSa_static_NPCs — простой спавн NPC по координатам
  vorp_menu        — исходный код меню (client/main.lua)

  ═══════════════════════════════════════════════
  ЛОВУШКИ RedM — КЛИЕНТ (GTA V → RedM замены):
  ═══════════════════════════════════════════════

  ❌ SetPedCanBeTargetted()       → SetEntityCanBeDamaged()
  ❌ SetPedDiesWhenInjured()      → SetEntityInvincible()
  ❌ SetRandomOutfitVariation()   → Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
  ❌ Blip.AddForCoords()          → BlipAddForCoords(1664425300, x, y, z)
  ❌ Blip.SetName()               → SetBlipName(blip, name)
  ❌ BoxZone / PolyZone           → простая дистанция #(a - b)
  ❌ BeginTextCommandDisplayHelp  → UiPrompt* система
  ❌ LocalPlayer.state.isLoggedIn → vorp:SelectedCharacter event

  ═══════════════════════════════════════════════
  ЛОВУШКИ VORP MENU:
  ═══════════════════════════════════════════════

  ❌ exports.vorp_menu:openMenu(...)  → НЕТ такого экспорта!
  ❌ exports.vorp_menu:closeAll()     → НЕТ такого экспорта!
  ❌ data.value в callback            → nil! Используй data.current.value
  ❌ subtitle = "text"                → параметр называется subtext

  ✅ local MenuData = exports.vorp_menu:GetMenuData()
  ✅ MenuData.Open('default', GetCurrentResourceName(), id, {...}, submitFn, cancelFn)
  ✅ data.current.value — значение выбранного элемента
  ✅ MenuData.CloseAll()

  ═══════════════════════════════════════════════
  ЛОВУШКИ VORP CORE — СЕРВЕР:
  ═══════════════════════════════════════════════

  ❌ character.getMoney              → nil! Используй character.money
  ❌ character.getGold               → nil! Используй character.gold
  ❌ character.removeGold(n)         → nil! Используй character.removeCurrency(1, n)
  ❌ character.removeMoney(n)        → nil! Используй character.removeCurrency(0, n)
  ❌ user.getUsedCharacter()         → НЕ функция! Это свойство: user.getUsedCharacter

  ✅ character.money / character.gold      — баланс
  ✅ character.removeCurrency(0, n)        — снять доллары
  ✅ character.removeCurrency(1, n)        — снять золото
  ✅ character.addCurrency(0, n)           — добавить доллары
  ✅ character.addCurrency(1, n)           — добавить золото

  ═══════════════════════════════════════════════
  ОБЩЕЕ ПРАВИЛО:
  ═══════════════════════════════════════════════

  Если функция вызывает "attempt to call a nil value" —
  она НЕ существует в RedM. Ищи native hash (0x...) в рабочих
  скриптах и вызывай через Citizen.InvokeNative(hash, args...)

  Если экспорт вызывает "No such export" —
  читай исходный код ресурса, ищи exports("Name", ...) чтобы
  узнать реальные имена экспортов.

  Если свойство = nil при обращении как character.getSomething —
  попробуй character.something (прямое свойство без get).

  ДАТА СОЗДАНИЯ: 2026-03-11
  ПОСЛЕДНЕЕ ОБНОВЛЕНИЕ: 2026-03-11
]]
