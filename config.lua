Config = {}

-- Bounty board location
Config.BountyBoardLocation = vector3(440.84, -981.14, 30.69) -- Mission Row PD

-- Configure how often bounties refresh (in minutes)
Config.RefreshTime = 60

-- Configure minimum job grade required to access bounties
Config.MinimumGrade = 0

-- Configure if players should get reputation for completing bounties
Config.UseReputation = true

-- Difficulty settings
Config.Difficulties = {
    ["Easy"] = {
        models = {"a_m_m_hillbilly_01", "a_m_m_farmer_01", "a_m_m_rurmeth_01"},
        weapons = {"WEAPON_PISTOL", "WEAPON_BAT", "WEAPON_KNIFE"},
        health = 150,
        armor = 0,
        accuracy = 40,
        reward = {min = 500, max = 1000}
    },
    ["Medium"] = {
        models = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03", "g_m_y_ballasout_01"},
        weapons = {"WEAPON_PISTOL", "WEAPON_APPISTOL", "WEAPON_SAWNOFFSHOTGUN"},
        health = 200,
        armor = 50,
        accuracy = 60,
        reward = {min = 1000, max = 2000}
    },
    ["Hard"] = {
        models = {"g_m_y_salvaboss_01", "g_m_m_mexboss_01", "g_m_m_mexboss_02"},
        weapons = {"WEAPON_COMBATPISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE"},
        health = 300,
        armor = 100,
        accuracy = 80,
        reward = {min = 2000, max = 3500}
    }
}

-- List of possible spawn locations for bounty targets
Config.Locations = {
    {area = "Sandy Shores", coords = vector3(1895.65, 3715.89, 32.75), heading = 215.0},
    {area = "Grapeseed", coords = vector3(2548.57, 4668.98, 33.15), heading = 128.0},
    {area = "Paleto Bay", coords = vector3(-15.29, 6293.21, 31.38), heading = 45.0},
    {area = "Vinewood Hills", coords = vector3(-1546.35, 137.05, 55.65), heading = 300.0},
    {area = "Vespucci Beach", coords = vector3(-1365.54, -1159.15, 4.12), heading = 90.0},
    {area = "El Burro Heights", coords = vector3(1365.87, -2088.76, 52.0), heading = 180.0},
    {area = "Harmony", coords = vector3(585.27, 2788.53, 42.13), heading = 2.0},
    {area = "Great Chaparral", coords = vector3(-386.12, 2587.32, 90.13), heading = 270.0},
    {area = "Davis", coords = vector3(97.59, -1927.71, 20.8), heading = 320.0},
    {area = "Mirror Park", coords = vector3(1151.34, -645.02, 57.39), heading = 75.0}
}