Config = {}

-- Интервал между спавном новых событий (секунды)
Config.EventInterval = 60

-- Максимум одновременных событий на одного клиента
Config.MaxEvents = 3

-- Событие спавнится в этом радиусе от центра зоны (метры)
Config.SpawnDistance = 120.0

-- Если игрок удалился дальше — событие удаляется
Config.DespawnDistance = 200.0

-- ─── Типы событий ─────────────────────────────────────────────────────────────
-- weight   — вероятность выбора относительно других событий
-- duration — максимальная продолжительность (сек), потом NPC удаляются
Config.Events = {
    fight = {
        enabled  = true,
        weight   = 25,
        duration = 90,
    },
    drunk = {
        enabled  = true,
        weight   = 15,
        duration = 180,
    },
    chase = {
        enabled  = true,
        weight   = 20,
        duration = 120,
    },
    brawl = {
        enabled  = true,
        weight   = 20,
        duration = 90,
    },
    body = {
        enabled  = true,
        weight   = 10,
        duration = 300,   -- тело лежит дольше
    },
    robbery = {
        enabled  = true,
        weight   = 20,
        duration = 60,
    },
    argument = {
        enabled  = true,
        weight   = 15,
        duration = 120,
    },
    wolf_pack = {
        enabled  = true,
        weight   = 15,
        duration = 120,
    },
    bear_sighting = {
        enabled  = true,
        weight   = 8,
        duration = 180,
    },
    runaway_horse = {
        enabled  = true,
        weight   = 12,
        duration = 90,
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
Config.Models = {
    -- Обычные жители для драки/пьяного
    males = {
        "A_M_M_ValFarmer_01",
        "S_M_M_BwmWorker_01",
        "S_M_M_CghWorker_01",
        "S_M_M_LiveryWorker_01",
        "A_M_M_BiVWorker_01",
    },
    -- Шерифы для погони
    law = {
        "U_M_M_ValSheriff_01",
        "U_M_M_RhdSheriff_01",
    },
    -- Разбойники/беглецы для погони
    outlaws = {
        "G_M_M_UniBanditos_01",
        "U_M_M_BHT_BANDITOMINE",
        "U_M_M_BHT_BANDITOSHACK",
    },
    -- Животные (спавн на окраине города)
    wolves = {
        "A_C_Wolf",
        "A_C_Wolf_Medium",
    },
    bears = {
        "A_C_Bear_01",
        "A_C_BearBlack_01",
    },
    horses = {
        "A_C_Horse_AmericanPaint_Overo",
        "A_C_Horse_AmericanStandardbred_Black",
        "A_C_Horse_Andalusian_DarkBay",
    },
}
