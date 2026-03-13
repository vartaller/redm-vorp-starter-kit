Config = {}

-- Интервал между спавном новых событий (секунды)
Config.EventInterval = 90

-- Максимум одновременных событий на одного клиента
Config.MaxEvents = 3

-- Событие спавнится в этом радиусе от центра зоны (метры)
Config.SpawnDistance = 80.0

-- Если игрок удалился дальше — событие удаляется
Config.DespawnDistance = 200.0

-- ─── Типы событий ─────────────────────────────────────────────────────────────
-- weight   — вероятность выбора относительно других событий
-- duration — максимальная продолжительность (сек), потом NPC удаляются
Config.Events = {
    fight = {
        enabled  = true,
        weight   = 40,
        duration = 90,
    },
    drunk = {
        enabled  = true,
        weight   = 30,
        duration = 180,
    },
    chase = {
        enabled  = true,
        weight   = 30,
        duration = 120,
    },
}

-- ─── Зоны городов ─────────────────────────────────────────────────────────────
-- NPC спавнятся в радиусе radius от pos
Config.SpawnZones = {
    { name = "Valentine",  pos = vector3( -284.0,  797.0, 119.0), radius = 80.0  },
    { name = "Strawberry", pos = vector3(-1796.0, -405.0, 161.0), radius = 60.0  },
    { name = "SaintDenis", pos = vector3( 2705.0,-1238.0,  46.0), radius = 100.0 },
    { name = "Rhodes",     pos = vector3( 1245.0,-1292.0,  76.0), radius = 60.0  },
    { name = "Armadillo",  pos = vector3(-3690.0,-2660.0, -14.0), radius = 60.0  },
}

-- ─── Модели педов ─────────────────────────────────────────────────────────────
-- Если модель не спавнится в игре — замени на рабочую через EasyAdmin → Ped Spawner
Config.Models = {
    -- Обычные жители для драки/пьяного
    males = {
        "a_m_m_saloon_fight_01",
        "a_m_y_saloon_fight_01",
        "a_m_o_saloon_fight_01",
        "a_m_m_miningtown01",
        "a_m_m_miningtown02",
    },
    -- Шерифы/стражники для погони
    law = {
        "g_m_m_unisheriff_01",
        "g_m_m_unisheriff_02",
    },
    -- Разбойники/беглецы для погони
    outlaws = {
        "g_m_m_unibounty_01",
        "a_m_m_rancher01",
    },
}
