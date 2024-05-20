local QBCore = exports['qb-core']:GetCoreObject()

-- Events

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    for _ = 1, math.random(1, Config.MaxItemsReceived), 1 do
        local randItem = Config.ItemTable[math.random(1, #Config.ItemTable)]
        local amount = math.random(Config.MinItemReceivedQty, Config.MaxItemReceivedQty)
        exports['qb-inventory']:AddItem(src, randItem, amount, false, false, 'qb-recyclejob:server:getItem')
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add')
        Wait(500)
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        exports['qb-inventory']:AddItem(src, Config.ChanceItem, 1, false, false, 'qb-recyclejob:server:getItem')
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChanceItem], 'add')
    end

    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        exports['qb-inventory']:AddItem(src, Config.LuckyItem, random, false, false, 'qb-recyclejob:server:getItem')
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LuckyItem], 'add')
    end
end)
