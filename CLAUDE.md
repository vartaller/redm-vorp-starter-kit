# RedM Private Server — CLAUDE.md

## Что это
Приватный RedM-сервер (RDR2 multiplayer) на базе фреймворка **VORP** (Vanilla Online Role Play).
Язык скриптов: **Lua**. Все ресурсы — в `resources/`.

Сервер создан для небольшой компании друзей. Концепция — **полноценный игровой мир без RP-обязанностей**:
все роли (доктор, почтальон, бармен, торговцы и т.д.) должны выполнять NPC, а не живые игроки.
В будущем возможен переход в RP-формат.

## Сервер
- IP: `185.223.30.219:30322`
- Game build: `1491` (September 2022 update)
- DB: MariaDB на ZAP-hosting, через `oxmysql`
- Конфиг сервера: `server.cfg`

## Структура проекта
```
dev/
├── server.cfg          # главный конфиг, список ensure
├── resources/          # активные скрипты
├── trash/              # оригиналы / архив / резервные копии
└── docs/               # документация по RDR3 нативам
    ├── RDR3natives/
    ├── RDR3-Native-Flags-And-Enums/
    ├── _redm_scripting_reference/
    └── fivem/
```

## Кастомные скрипты (написаны с нуля / не из VORP)
| Ресурс | Описание |
|--------|----------|
| `bln_lib` | библиотека для bln_* скриптов |
| `bln_loot_hunter` | лутинг контейнеров и педов, конфиг предметов/шанса |
| `bln_notify` | система уведомлений |
| `bln_playername` | имена игроков над головой |
| `vorp_bartenders` | бармены (взято из `trash/my-resources/`, не оригинальный VORP) |

## Модифицированные стоковые скрипты
Скрипты, которые есть и в `resources/` и в `trash/` — **могут быть изменены** относительно оригинала:
`vorp_housing` (оригинал: `trash/VORP-Housing`), `vorp_saloon` (оригинал: `trash/vorp_saloons`).
Остальные стоковые VORP-скрипты вероятно не изменены, но могут быть изменены в любой момент.

> **Принцип:** `trash/` = оригиналы/архив, `resources/` = рабочие версии.

## Архитектура VORP

### Структура типичного ресурса
```
resource_name/
├── fxmanifest.lua   # объявление файлов (client_scripts, server_scripts, shared_scripts)
├── config.lua       # конфиг (Config = {})
├── client/          # или client.lua
│   └── main.lua
└── server/          # или server.lua
    └── main.lua
```

### Ключевые паттерны
```lua
-- Получить игрока на сервере
local user = exports.vorp_core:GetUser(source)
local character = user.getUsedCharacter

-- Добавить предмет игроку
exports.vorp_inventory:addItem(source, itemName, count)

-- Проверить наличие предмета
exports.vorp_inventory:canCarryItem(source, itemName, count)

-- Деньги
exports.vorp_core:getUser(source).character.money
TriggerClientEvent('vorp_core:client:UpdateMoney', source)
```

### Ключевые зависимости (порядок ensure важен)
```
oxmysql → vorp_lib → vorp_core → vorp_inventory → vorp_character → остальные
```

### Основные экспорты для межскриптового взаимодействия
- `vorp_core` — пользователи, персонажи, деньги
- `vorp_inventory` — предметы
- `vorp_menu` — UI меню
- `vorp_progressbar` — прогресс-бар действий
- `bln_notify` — уведомления (кастомный, замена vorp_notify)
- `PolyZone` — зоны на карте
- `syn_minigame` — мини-игры (взлом и т.п.)

## Частые задачи

### Добавить новый предмет в инвентарь
1. Зарегистрировать в `vorp_inventory` (таблица `items` в БД или конфиг)
2. Использовать в скриптах через `exports.vorp_inventory`

### Добавить NUI (веб-интерфейс)
Папка `html/` внутри ресурса, регистрируется в `fxmanifest.lua` как `ui_page`.

### Отладка
- `EasyAdmin` — F10, панель администратора в игре
- Логи сервера в консоли txAdmin

## Известные проблемы (баг-трекер)

| # | Проблема | Скрипт | Статус |
|---|----------|--------|--------|
| 1 | Предметы из лута/трав отсутствуют в БД — при сборе/лутании ошибка "предмет не найден" | `vorp_inventory`, `bln_loot_hunter`, `vorp_herbs` | 🔴 не исправлено |
| 2 | Почта работает, но нет NPC-сотрудников (некому отдавать/принимать посылки) | `vorp_postman` / `vorp_mailbox` | 🔴 не исправлено |
| 3 | Доктор недоступен (закрыт / NPC нет) | `vorp_medic` | 🔴 не исправлено |
| 4 | Снаряжение для лошади можно купить, но в магазине лошади оно не отображается | `vorp_stables` / `vorp_stores` | 🔴 не исправлено |
| 5 | Постэффекты опьянения наступают резко, без плавного нарастания как в оригинальной игре | `vorp_saloon` / `vorp_bartenders` / `vorp_metabolism` | 🔴 не исправлено |

> Обновляй статусы: 🔴 не исправлено · 🟡 в процессе · 🟢 исправлено

## Нативы RDR3
Документация лежит локально в `docs/`:
- `docs/RDR3natives/` — все нативы с описаниями
- `docs/_redm_scripting_reference/` — справочник RedM scripting
- `docs/RDR3-Native-Flags-And-Enums/` — флаги и энумы
