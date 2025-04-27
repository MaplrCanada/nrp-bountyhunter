local QBCore = exports['qb-core']:GetCoreObject()

local ActiveBounties = {}

function GenerateRandomBounty()
    local loc = Config.BountyLocations[math.random(#Config.BountyLocations)]
    local pedModel = 'g_m_y_ballaorig_01'
    local bountyId = math.random(1000, 9999)

    ActiveBounties[bountyId] = {
        id = bountyId,
        location = loc,
        model = pedModel,
        reward = math.random(Config.BountyRewardRange[1], Config.BountyRewardRange[2]),
        active = true
    }

    TriggerClientEvent('qb-bountyhunter:client:updateBounties', -1, ActiveBounties)
end

RegisterNetEvent('qb-bountyhunter:server:requestBounty', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == 'bountyhunter' then
        if #ActiveBounties == 0 then
            GenerateRandomBounty()
        end
        TriggerClientEvent('qb-bountyhunter:client:updateBounties', src, ActiveBounties)
    else
        TriggerClientEvent('QBCore:Notify', src, "You are not a registered bounty hunter!", "error")
    end
end)

RegisterNetEvent('qb-bountyhunter:server:bountyCompleted', function(bountyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if ActiveBounties[bountyId] then
        Player.Functions.AddMoney('cash', ActiveBounties[bountyId].reward)
        ActiveBounties[bountyId] = nil
        TriggerClientEvent('qb-bountyhunter:client:updateBounties', -1, ActiveBounties)
        TriggerClientEvent('QBCore:Notify', src, "Bounty collected! Good work.", "success")
    end
end)
