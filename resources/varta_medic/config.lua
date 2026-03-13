Config = {}

-- Клавиша взаимодействия (G)
Config.Key = 0x760A9C6F

-- Расстояние спавна NPC (метры)
Config.NpcDistanceSpawn = 60.0

-- Расстояние показа подсказки (метры)
Config.InteractDistance = 2.0

-- Стоимость услуг ($)
Config.Prices = {
    heal    = 5.0,   -- восстановить здоровье
    stamina = 3.0,   -- восстановить выносливость
    full    = 8.0,   -- полное лечение (здоровье + выносливость)
}

-- Количество восстановления (0–100, внутренние ядра персонажа)
Config.HealValues = {
    health  = 50,   -- heal
    stamina = 50,   -- stamina
    full    = 100,  -- full
}

-- Локации докторов
-- npc   = vector4(x, y, z, heading) — позиция и поворот NPC
-- model = модель педа для данной локации
-- blip  = vector3(x, y, z)          — позиция иконки на карте
-- name  = название (показывается в подсказке и в меню)
Config.Locations = {
    Valentine = {
        name  = "Доктор — Валентайн",
        model = "U_M_M_ValDoctor_01",
        npc   = vector4(-288.82, 808.44, 119.43, 180.0),
        blip  = vector3(-288.82, 808.44, 119.43),
    },
    Strawberry = {
        name  = "Доктор — Строберри",
        model = "U_M_M_RHDDOCTOR_01",    -- Rhodes doctor (ближайший к Strawberry)
        npc   = vector4(-1803.33, -432.59, 158.83, 90.0),
        blip  = vector3(-1803.33, -432.59, 158.83),
    },
    SaintDenis = {
        name  = "Доктор — Сен-Дени",
        model = "CS_SDDoctor_01",
        npc   = vector4(2721.29, -1233.11, 50.37, 270.0),
        blip  = vector3(2721.29, -1233.11, 50.37),
    },
}
