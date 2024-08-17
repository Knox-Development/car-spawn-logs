local lastVehicle = nil
local isVehicleLogged = false

RegisterNetEvent('vehLog:spawnVehicle')
AddEventHandler('vehLog:spawnVehicle', function(vehicle)
    local player = PlayerId()
    local playerServerId = GetPlayerServerId(player)
    local playerName = GetPlayerName(player)
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)

    TriggerServerEvent('vehLog:sendToWebhook', playerServerId, playerName, vehicleName, vehiclePlate, NetworkGetNetworkIdFromEntity(vehicle))
end)

CreateThread(function()
    while true do
        Wait(1000) -- Check every second

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                if lastVehicle ~= vehicle then
                    if not isVehicleLogged then
                        isVehicleLogged = true
                    else
                        TriggerEvent('vehLog:spawnVehicle', vehicle)
                    end
                    lastVehicle = vehicle
                end
            end
        else
            lastVehicle = nil
            isVehicleLogged = false
        end
    end
end)

RegisterNetEvent('vehLog:deleteVehicle')
AddEventHandler('vehLog:deleteVehicle', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)
