-- nrp-bountyhunter/client/main.lua

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local activeBounty = nil
local blip = nil
local targetPed = nil
local targetBlip = nil

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Create bounty board at Mission Row PD
CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local bountyBoardCoords = vector3(440.84, -981.14, 30.69) -- Mission Row PD location
        local dist = #(playerCoords - bountyBoardCoords)
        
        if dist < 10 then
            sleep = 0
            DrawMarker(2, bountyBoardCoords.x, bountyBoardCoords.y, bountyBoardCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            
            if dist < 1.5 then
                DrawText3D(bountyBoardCoords.x, bountyBoardCoords.y, bountyBoardCoords.z + 0.2, "~g~E~w~ - View Bounty Board")
                
                if IsControlJustPressed(0, 38) then -- E key
                    if PlayerData.job and PlayerData.job.name == 'bountyhunter' then
                        OpenBountyMenu()
                    else
                        QBCore.Functions.Notify("You need to be a Bounty Hunter to use this board!", "error")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Open the bounty board menu
function OpenBountyMenu()
    TriggerServerEvent('nrp-bountyhunter:server:GetAvailableBounties')
end

-- Display bounty options
RegisterNetEvent('nrp-bountyhunter:client:ShowBountyMenu', function(bounties)
    local bountiesMenu = {
        {
            header = "Bounty Board",
            isMenuHeader = true
        }
    }
    
    for i, bounty in ipairs(bounties) do
        table.insert(bountiesMenu, {
            header = bounty.name .. " - $" .. bounty.reward,
            txt = "Difficulty: " .. bounty.difficulty .. " | Location: " .. bounty.area,
            params = {
                event = "nrp-bountyhunter:client:AcceptBounty",
                args = bounty
            }
        })
    end
    
    table.insert(bountiesMenu, {
        header = "Close Menu",
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(bountiesMenu)
end)

-- Accept a bounty
RegisterNetEvent('nrp-bountyhunter:client:AcceptBounty', function(bounty)
    if activeBounty then
        QBCore.Functions.Notify("You already have an active bounty! Complete it or cancel it first.", "error")
        return
    end
    
    activeBounty = bounty
    QBCore.Functions.Notify("Bounty accepted. Find and capture " .. bounty.name .. " in " .. bounty.area, "success")
    
    -- Create a general area blip
    local coords = bounty.coords
    blip = AddBlipForRadius(coords.x, coords.y, coords.z, 150.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)
    
    -- Create the target NPC
    CreateTargetPed(bounty)
end)

-- Create the target NPC for the bounty
function CreateTargetPed(bounty)
    local coords = bounty.coords
    
    -- Request the model
    local model = bounty.model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    -- Create the ped
    targetPed = CreatePed(4, model, coords.x, coords.y, coords.z, bounty.heading, false, true)
    
    -- Set ped properties
    SetPedArmour(targetPed, bounty.armor)
    SetPedMaxHealth(targetPed, bounty.health)
    SetEntityHealth(targetPed, bounty.health)
    SetPedAccuracy(targetPed, bounty.accuracy)
    SetPedCombatAttributes(targetPed, 46, true) -- BF_AlwaysFight
    SetPedFleeAttributes(targetPed, 0, false)
    SetPedCombatRange(targetPed, 2) -- Far
    GiveWeaponToPed(targetPed, bounty.weapon, 500, false, true)
    
    -- Make ped wander in the area
    TaskWanderInArea(targetPed, coords.x, coords.y, coords.z, 50.0, 10.0, 10.0)
    
    -- Monitor distance to the ped
    CreateThread(function()
        while targetPed and activeBounty do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local targetCoords = GetEntityCoords(targetPed)
            local dist = #(playerCoords - targetCoords)
            
            -- Create precise blip when player gets closer
            if dist < 100.0 and not targetBlip then
                targetBlip = AddBlipForEntity(targetPed)
                SetBlipSprite(targetBlip, 303) -- Bounty blip
                SetBlipColour(targetBlip, 1) -- Red
                SetBlipScale(targetBlip, 0.8)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Bounty Target")
                EndTextCommandSetBlipName(targetBlip)
                
                -- Make ped attack player when close
                TaskCombatPed(targetPed, PlayerPedId(), 0, 16)
            end
            
            -- Check if ped is dead
            if IsEntityDead(targetPed) then
                QBCore.Functions.Notify("Target eliminated. Return to the police station to collect your reward.", "success")
                if DoesBlipExist(blip) then RemoveBlip(blip) end
                if DoesBlipExist(targetBlip) then RemoveBlip(targetBlip) end
                
                -- Create marker for return
                local returnCoords = vector3(440.84, -981.14, 30.69) -- Mission Row PD
                local returnBlip = AddBlipForCoord(returnCoords.x, returnCoords.y, returnCoords.z)
                SetBlipSprite(returnBlip, 162) -- Money sign
                SetBlipColour(returnBlip, 2) -- Green
                SetBlipRoute(returnBlip, true)
                
                -- Create thread to monitor return to PD
                CreateThread(function()
                    while true do
                        local sleep = 1000
                        local playerPos = GetEntityCoords(PlayerPedId())
                        local distance = #(playerPos - returnCoords)
                        
                        if distance < 10.0 then
                            sleep = 0
                            DrawMarker(2, returnCoords.x, returnCoords.y, returnCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, true, false, false, false)
                            
                            if distance < 1.5 then
                                DrawText3D(returnCoords.x, returnCoords.y, returnCoords.z + 0.2, "~g~E~w~ - Collect Bounty Reward")
                                
                                if IsControlJustPressed(0, 38) then -- E key
                                    TriggerServerEvent('nrp-bountyhunter:server:CompleteBounty', activeBounty.id)
                                    activeBounty = nil
                                    RemoveBlip(returnBlip)
                                    break
                                end
                            end
                        end
                        Wait(sleep)
                    end
                end)
                
                break
            end
            
            Wait(1000)
        end
    end)
end

-- Cancel active bounty
RegisterCommand('cancelbounty', function()
    if activeBounty then
        if DoesBlipExist(blip) then RemoveBlip(blip) end
        if DoesBlipExist(targetBlip) then RemoveBlip(targetBlip) end
        
        if targetPed and DoesEntityExist(targetPed) then
            DeleteEntity(targetPed)
        end
        
        activeBounty = nil
        QBCore.Functions.Notify("You've canceled your active bounty.", "info")
    else
        QBCore.Functions.Notify("You don't have an active bounty.", "error")
    end
end, false)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if DoesBlipExist(blip) then RemoveBlip(blip) end
    if DoesBlipExist(targetBlip) then RemoveBlip(targetBlip) end
    
    if targetPed and DoesEntityExist(targetPed) then
        DeleteEntity(targetPed)
    end
    
    activeBounty = nil
end)