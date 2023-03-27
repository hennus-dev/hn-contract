QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('hn-contract:client:OpenContract', function()
    local player = GetClosestPlayer()
    if player ~= nil then

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle  and vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            local data = {}
            data.vehicle = {
                plate = plate,
                model = model,
                hash = GetEntityModel(vehicle)
            }
            QBCore.Functions.TriggerCallback('hn-contract:server:CheckPlayer', function(result)
                data.buyer = {
                    name = result.charinfo.firstname .. ' ' .. result.charinfo.lastname,
                    citizenid = result.citizenid,
                    id = player
                }
                data.seller = {
                    name = QBCore.Functions.GetPlayerData().charinfo.firstname .. ' ' .. QBCore.Functions.GetPlayerData().charinfo.lastname,
                    citizenid = QBCore.Functions.GetPlayerData().citizenid,
                    id = GetPlayerServerId(PlayerId())
                }
                SendNUIMessage({
                    action = 'init',
                    data = data
                })
                SetNuiFocus(true, true)
            end, player)
        else
            QBCore.Functions.Notify('No estás en un vehículo', 'error')
        end
    else
        QBCore.Functions.Notify('No hay jugadores cerca', 'error')
    end    

end)

RegisterNetEvent('hn-contract:client:SendContract', function(data)
    SendNUIMessage({
        action = 'buyer',
        data = data
    })
    SetNuiFocus(true, true)
end)

function GetClosestPlayer()
    local coords = GetEntityCoords(PlayerPedId())
    local tempDist = 0
    local closestPlayer = nil0
    for _, player in ipairs(GetActivePlayers()) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        if #(coords - targetCoords) < 4.0 and #(coords - targetCoords) < 15 and target ~= PlayerPedId() then
            if tempDist == 0 then
                tempDist = #(coords - targetCoords)
                closestPlayer = GetPlayerServerId(player)
            else
                if #(coords - targetCoords) < tempDist and target ~= PlayerPedId() and #(coords - targetCoords) < 15  then
                    tempDist = #(coords - targetCoords)
                    closestPlayer = GetPlayerServerId(player)
                end
            end
        end
    end
    return closestPlayer
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('identifier', function(data, cb)
    QBCore.Functions.TriggerCallback('hn-contract:server:CheckPlayer', function(result)
        if not result then
            cb(nil)
            return
        end
        local  info = {
            name = result.charinfo.firstname .. ' ' .. result.charinfo.lastname,
            citizenid = result.citizenid,
            id = player
        }
        cb(info)
    end, tonumber(data.id))
end)

RegisterNUICallback('accept', function(data)
    TriggerServerEvent('hn-contract:server:Confirm', data)
end)

RegisterNUICallback('sendBuyer', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local plate = GetVehicleNumberPlateText(vehicle)
    if string.upper(plate) ~= string.upper(data.vehicle.plate) then
        SetVehicleNumberPlateText(vehicle, string.upper(data.vehicle.plate))
        Wait(300)
        TriggerEvent("vehiclekeys:client:SetOwner",GetVehicleNumberPlateText(vehicle))
    end
    TriggerServerEvent('hn-contract:server:SendContract', data)
    cb('ok')
end)