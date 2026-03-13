--[[
═══════════════════════════════════════════════════════════════
  RedM / VORP — СПРАВОЧНИК: ПРОВЕРКА ДИСТАНЦИИ / ВЗАИМОДЕЙСТВИЕ
  Проверено на практике. Источники: vorp_stores, vorp_stables.
═══════════════════════════════════════════════════════════════

  ПРОБЛЕМА:
  PolyZone — внешняя библиотека, которая может быть не установлена.
  BoxZone:Create() вызовет nil error, если PolyZone отсутствует.

  РЕШЕНИЕ:
  Все рабочие VORP-скрипты используют простую проверку дистанции.
  Это нативный Lua — никаких зависимостей.
]]

-- ─────────────────────────────────────────────
-- 1. ПРОСТАЯ ПРОВЕРКА ДИСТАНЦИИ (рекомендуется)
-- ─────────────────────────────────────────────

-- Вариант из vorp_stores:
local function getDistanceFromCoords(targetVec3)
    local playerPos = GetEntityCoords(PlayerPedId())
    return #(playerPos - targetVec3)
end

-- Использование:
local dist = getDistanceFromCoords(vector3(x, y, z))
if dist <= 3.0 then
    -- игрок рядом
end

-- Вариант из vorp_stables (без vector3):
local function inDistance(a, b, d)
    local sqrMag = math.pow(a[1] - b[1], 2) + math.pow(a[2] - b[2], 2) + math.pow(a[3] - b[3], 2)
    return sqrMag <= d * d
end

-- ─────────────────────────────────────────────
-- 2. ОПТИМИЗАЦИЯ GAME LOOP
-- ─────────────────────────────────────────────

--[[
  ВАЖНО: Wait(0) каждый кадр = 100% загрузка CPU.
  Рабочие скрипты используют адаптивный sleep:
  - Далеко от всех точек → Wait(1000) (проверка раз в секунду)
  - Рядом с точкой → Wait(0) (каждый кадр, для промпта)
]]

CreateThread(function()
    while true do
        local sleep = 1000  -- по умолчанию: проверяем редко

        for key, point in pairs(Config.Points) do
            local dist = getDistanceFromCoords(point.coords)

            if dist <= point.interactDistance then
                sleep = 0  -- рядом: проверяем каждый кадр
                -- показываем промпт, проверяем нажатие
                break
            end
        end

        Wait(sleep)
    end
end)

-- ─────────────────────────────────────────────
-- 3. ДИНАМИЧЕСКИЙ СПАВН/ДЕСПАВН NPC (vorp_stores)
-- ─────────────────────────────────────────────

--[[
  vorp_stores спавнит NPC только когда игрок рядом (< 20 юнитов)
  и удаляет когда далеко. Это экономит ресурсы.

  Для простых скриптов (10 NPC) — можно спавнить всех сразу.
  Для сложных (50+ NPC) — лучше динамический спавн.
]]

-- Упрощённый пример из vorp_stores:
if dist < 20.0 then
    if not npcHandle then
        SpawnNPC()  -- спавним
    end
else
    if npcHandle then
        DeleteEntity(npcHandle)  -- удаляем
        npcHandle = nil
    end
end

-- ─────────────────────────────────────────────
-- 4. ❌ НЕ ИСПОЛЬЗОВАТЬ (внешние зависимости)
-- ─────────────────────────────────────────────

--[[
  PolyZone / BoxZone:
    BoxZone:Create(...)           → nil error если PolyZone не установлен
    zone:onPlayerInOut(...)       → то же самое

  Если нужны зоны — используй простую дистанцию.
  Не добавляй 'PolyZone' в dependencies в fxmanifest.lua,
  если не уверен что он установлен на сервере.
]]
