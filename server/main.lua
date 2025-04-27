-- nrp-bountyhunter/server/main.lua

local QBCore = exports['qb-core']:GetCoreObject()
local availableBounties = {}
local activeBounties = {}
local bountyLocations = {
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

local bountyTargets = {
    {
        difficulty = "Easy",
        models = {"a_m_m_hillbilly_01", "a_m_m_farmer_01", "a_m_m_rurmeth_01"},
        weapons = {"WEAPON_PISTOL", "WEAPON_BAT", "WEAPON_KNIFE"},
        health = 150,
        armor = 0,
        accuracy = 40,
        reward = {min = 500, max = 1000}
    },
    {
        difficulty = "Medium",
        models = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03", "g_m_y_ballasout_01"},
        weapons = {"WEAPON_PISTOL", "WEAPON_APPISTOL", "WEAPON_SAWNOFFSHOTGUN"},
        health = 200,
        armor = 50,
        accuracy = 60,
        reward = {min = 1000, max = 2000}
    },
    {
        difficulty = "Hard",
        models = {"g_m_y_salvaboss_01", "g_m_m_mexboss_01", "u_m_y_juggernaut_01"},
        weapons = {"WEAPON_COMBATPISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE"},
        health = 300,
        armor = 100,
        accuracy = 80,
        reward = {min = 2000, max = 3500}
    }
}

-- Generate new bounties every hour
function GenerateBounties()
    availableBounties = {}
    
    for i = 1, math.random(3, 6) do
        local targetType = bountyTargets[math.random(1, #bountyTargets)]
        local location = bountyLocations[math.random(1, #bountyLocations)]
        local model = targetType.models[math.random(1, #targetType.models)]
        local weapon = targetType.weapons[math.random(1, #targetType.weapons)]
        local reward = math.random(targetType.reward.min, targetType.reward.max)
        
        -- Create slight variation in spawn location
        local offsetX = math.random(-50, 50)
        local offsetY = math.random(-50, 50)
        local coords = vector3(location.coords.x + offsetX, location.coords.y + offsetY, location.coords.z)
        
        -- Generate a random name for the bounty
        local firstNames = {"John", "Mike", "Trevor", "Steve", "Billy", "Ray", "Chester", "Cletus", "Earl", "Buck"}
        local lastNames = {"Johnson", "Smith", "Williams", "Jackson", "Thompson", "Davis", "Rodriguez", "Martinez", "Gonzalez", "Wilson"}
        local name = firstNames[math.random(1, #firstNames)] .. " " .. lastNames[math.random(1, #lastNames)]
        
        table.insert(availableBounties, {
            id = i,
            name = name,
            model = GetHashKey(model),
            difficulty = targetType.difficulty,
            area = location.area,
            coords = coords,
            heading = location.heading,
            weapon = GetHashKey(weapon),
            health = targetType.health,
            armor = targetType.armor,
            accuracy = targetType.accuracy,
            reward = reward
        })
    end
end

-- Generate initial bounties when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    GenerateBounties()
    
    -- Schedule bounty refresh every hour
    SetTimeout(3600000, RecurringBountyGeneration)
end)

function RecurringBountyGeneration()
    GenerateBounties()
    SetTimeout(3600000, RecurringBountyGeneration)
end

-- Get available bounties
RegisterNetEvent('nrp-bountyhunter:server:GetAvailableBounties', function()
    local src = source
    TriggerClientEvent('nrp-bountyhunter:client:ShowBountyMenu', src, availableBounties)
end)

-- Complete a bounty
RegisterNetEvent('nrp-bountyhunter:server:CompleteBounty', function(bountyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    for i, bounty in ipairs(availableBounties) do
        if bounty.id == bountyId then
            -- Remove the bounty from available list
            table.remove(availableBounties, i)
            
            -- Add payment
            Player.Functions.AddMoney("cash", bounty.reward, "bounty-reward")
            TriggerClientEvent('QBCore:Notify', src, "You received $" .. bounty.reward .. " for completing the bounty!", "success")
            
            -- Add reputation (if you want to implement this)
            -- Player.Functions.SetMetaData("bountyrep", (Player.PlayerData.metadata.bountyrep or 0) + 10)
            
            break
        end
    end
end)

-- Add some commands for admin control
QBCore.Commands.Add('refreshbounties', 'Refresh the bounty board (Admin Only)', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == "admin" or IsPlayerAceAllowed(src, "command") then
        GenerateBounties()
        TriggerClientEvent('QBCore:Notify', src, "Bounty board has been refreshed!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to do this.", "error")
    end
end)