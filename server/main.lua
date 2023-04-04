local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-recycle:server:getItem', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    for i = 1, math.random(1, Config.MaxItemsReceived) do
        local randItem = Config.ItemTable[math.random(#Config.ItemTable)]
        local amount = math.random(Config.MinItemReceivedQty, Config.MaxItemReceivedQty)
        player.Functions.AddItem(randItem, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add')
        Wait(500)
    end

    if math.random(100) < 7 then
        player.Functions.AddItem(Config.ChanceItem, 1, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChanceItem], 'add')
    end

    if math.random(10) == math.random(10) then
        local random = math.random(1, 3)
        player.Functions.AddItem(Config.LuckyItem, random)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LuckyItem], 'add')
    end
end)
