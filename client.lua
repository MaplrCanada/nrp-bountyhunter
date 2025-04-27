local QBCore = exports['qb-core']:GetCoreObject()
local Bounties = {}

RegisterNetEvent('qb-bountyhunter:client:updateBounties', function(bountyData)
    Bounties = bountyData
    SendNUIMessage({ action = "updateBounties", bounties = Bounties })
end)

-- Open bounty board
RegisterCommand('bounties', function()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    if #(pos - Config.BountyBoardLocation) < 5.0 then
        SetNuiFocus(true, true)
        TriggerServerEvent('qb-bountyhunter:server:requestBounty')
    else
        QBCore.Functions.Notify('No bounty board nearby!', 'error')
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startBounty', function(data, cb)
    local bounty = Bounties[data.id]
    if bounty then
        SpawnBounty(bounty)
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

function SpawnBounty(bounty)
    local model = bounty.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, bounty.location.x, bounty.location.y, bounty.location.z, 0.0, true, false)
    SetEntityAsMissionEntity(ped, true, true)
    TaskWanderStandard(ped, 10.0, 10)
    SetEntityHealth(ped, 200)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "qb-bountyhunter:client:captureBounty",
                icon = "fas fa-handcuffs",
                label = "Capture Bounty",
                bountyId = bounty.id,
                pedNetId = NetworkGetNetworkIdFromEntity(ped),
            }
        },
        distance = 2.5
    })
end

RegisterNetEvent('qb-bountyhunter:client:captureBounty', function(data)
    local bountyId = data.bountyId
    local ped = NetworkGetEntityFromNetworkId(data.pedNetId)

    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
        TriggerServerEvent('qb-bountyhunter:server:bountyCompleted', bountyId)
    end
end)
