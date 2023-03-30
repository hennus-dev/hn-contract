QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('contract', function(source, item)
    local src = source
    TriggerClientEvent('hn-contract:client:OpenContract', src)

end)

QBCore.Functions.CreateCallback('hn-contract:server:CheckPlayer', function(source, cb, player)
    local src = source
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(player))
    cb(OtherPlayer.PlayerData)
end)

RegisterNetEvent('hn-contract:server:SendContract', function(data)
    TriggerClientEvent('hn-contract:client:SendContract', tonumber(data.buyer.id), data)
end)

RegisterNetEvent('hn-contract:server:Confirm', function(data)
    local Player = QBCore.Functions.GetPlayer(tonumber(data.buyer.id))
    local license = Player.PlayerData.license
    local PlayerSeller = QBCore.Functions.GetPlayer(tonumber(data.seller.id))
    if not data.vehicle.price then
        TriggerClientEvent('QBCore:Notify', tonumber(data.buyer.id), 'la casilla del precio esta vacio.', 'error')
        TriggerClientEvent('QBCore:Notify', tonumber(data.seller.id), 'la casilla del precio esta vacio.', 'error')
        return
    end
    if not Player.PlayerData.money.bank or  tonumber(Player.PlayerData.money.bank) < tonumber(data.vehicle.price) then
        TriggerClientEvent('QBCore:Notify', tonumber(data.buyer.id), 'No tienes suficiente dinero en el banco', 'error')
        return
    end
    
    exports.oxmysql:query("SELECT * FROM `player_vehicles` WHERE  `plate` = @plate", {
        ['@plate'] = string.upper(data.vehicle.plate)
    }, function(result)
        if result[1] ~= nil then
            
            if PlayerSeller.PlayerData.citizenid == result[1].citizenid then
                if Player.Functions.RemoveMoney('bank', tonumber(data.vehicle.price), 'contract') then
                    PlayerSeller.Functions.AddMoney('bank', tonumber(data.vehicle.price), 'contract')
                    PlayerSeller.Functions.RemoveItem('contract', 1)
                end
                exports.oxmysql:query("UPDATE `player_vehicles` SET `citizenid` = @citizenid WHERE `plate` = @plate", {
                    ['@citizenid'] = data.buyer.citizenid,
                    ['@plate'] = string.upper(data.vehicle.plate)
                })
            else
                -- event notify
                TriggerClientEvent('QBCore:Notify', tonumber(data.buyer.id), 'Este vehiculo no es tuyo', 'error')
            end
        elseif Config.AddNewCars and QBCore.Functions.HasPermission(tonumber(data.seller.id), Config.Permission) then
            
            if Player.Functions.RemoveMoney('bank', tonumber(data.vehicle.price), 'contract') then
                PlayerSeller.Functions.AddMoney('bank', tonumber(data.vehicle.price), 'contract')
                PlayerSeller.Functions.RemoveItem('contract', 1)
            end
            exports.oxmysql:query("INSERT INTO `player_vehicles` (`license`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `garage`, `state`) VALUES(@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)", {
                ['@license'] = license,
                ['@citizenid'] = data.buyer.citizenid,
                -- data.vehicle.model:lower
                ['@vehicle'] = string.lower(data.vehicle.model),
                ['@hash'] = GetHashKey(data.vehicle.hash),
                ['@mods'] = json.encode({}),
                ['@plate'] = string.upper(data.vehicle.plate),
                ['@garage'] = 'pillboxgarage',
                ['@state'] = 0,
            })
        else
            -- evetn notify
            TriggerClientEvent('QBCore:Notify', tonumber(data.buyer.id), 'Este vehiculo no esta registrado en la base de datos', 'error')
        end
    end)
end)

exports['qb-core']:AddItem('contract', {
        ['name'] = 'contract',
        ['label'] = 'Contrato',
        ['weight'] = 100,
        ['type'] = 'item',
        ["image"] = "contract.png",
        ["unique"] = false,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "Un contrato de compraventa",

})