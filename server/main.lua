local QBCore = exports['qb-core']:GetCoreObject()

local Recieve = {
    {item = 'metalscrap', min = 1, max = 5},
    {item = 'plastic', min = 1, max = 5},
    {item = 'copper', min = 1, max = 5},
    {item = 'rubber', min = 1, max = 5},
    {item = 'iron', min = 1, max = 5},
    {item = 'aluminum', min = 1, max = 5},
    {item = 'steel', min = 1, max = 5},
    {item = 'glass', min = 1, max = 5},
}
local luckyItem = 'cryptostick' -- Item to be given as a lucky item
local maxRecieved = 5 -- Max items to be received
local dropLocation = Config.DropLocation
local LuckyItemChance = 20 -- 20% chance to get a lucky item
local uhohs = {}
local Sales, Stock, salesLoc = {}, {}, Config.SellPed


if Config.SellMaterials then 
    Sales = { -- key is item, value is price
        metalscrap = 2,
        plastic = 2,
        copper = 2,
        rubber = 2,
        iron = 2,
        aluminum = 2,
        steel = 2,
        glass = 2,
    }
end
if Config.LimitedMaterials then 
    Stock = { -- key is item, value is stock at restart
        metalscrap = 3000,
        plastic = 3000,
        copper = 3000,
        rubber = 3000,
        iron = 3000,
        aluminum = 3000,
        steel = 3000,
        glass = 3000,
    }
end


local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            QBCore.Functions.GetIdentifier(id, 'license'),
            QBCore.Functions.GetIdentifier(id, 'discord'),
            QBCore.Functions.GetIdentifier(id, 'ip'),
            reason,
            2147483647,
            'qb-recyclejob'
        })
    TriggerEvent('qb-log:server:CreateLog', 'recyclejob', 'Player Banned', 'red',
        string.format('%s was banned by %s for %s', GetPlayerName(id), 'qb-recyclejob', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

local function isClose(source, loc)
    local playerPed = GetPlayerPed(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local cid = Player.PlayerData.citizenid
    local playerCoords = GetEntityCoords(playerPed)
    local distance = nil

    if loc == 'turnIn' then
        distance = #(playerCoords - vector3(dropLocation.x, dropLocation.y, dropLocation.z))
    elseif loc == 'sell' then
        distance = #(playerCoords - vector3(salesLoc.x, salesLoc.y, salesLoc.z))
    else
        return false
    end

    if distance < 5.0 then
        return true
    else
        uhohs[cid] = uhohs[cid] + 1 or 0
        if uhohs[cid] >= 3 then
            exploitBan(source, 'Exploiting distance on qb-recyclejob')
        end
        return false
    end
end

QBCore.Functions.CreateCallback('qb-recyclejob:server:getPriceList', function(source, cb)
    local src = source
    if not isClose(src, 'sell') then return false end
    cb(Sales)
end)

local function adjustStock(item, change, amount)
    if not Config.LimitedMaterials then return end
    if change == 'add' then
        Stock[item] = Stock[item] + amount
    elseif change == 'remove' then
        Stock[item] = Stock[item] - amount
    end
end

local function checkStock(source, item, amount)
    if not Config.LimitedMaterials then return true end
    if Stock[item] >= amount then
        return true
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.out_of_stock', {item = item}), 'error')
        return false
    end
end

local function sellMaterials(src, item, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    local price = Sales[item] * amount
    local has = Player.Functions.GetItemByName(item)
    if has and has.amount < amount then
        amount = has.amount
        price = Sales[item] * amount
    end
    if Player.Functions.RemoveItem(item, amount) then
        Player.Functions.AddMoney('cash', price)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.sold', {amount = amount, item = QBCore.Shared.Items[item].label, price = price}), 'success')
        adjustStock(item, 'add', amount)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.nothing_to_sell'), 'error')
        return
    end
end

local function getItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.LimitedMaterials then
        if not checkStock(source, item, amount) then return end
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)
        adjustStock(item, 'remove', amount)
    else
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)
    end
end

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isClose(src, 'turnIn') then
        if not uhohs[src] then uhohs[src] = 1 return end
        uhohs[src] = uhohs[src] + 1 or 1
        if uhohs[src] >= 3 then
            exploitBan(src, 'Exploiting distance on qb-recyclejob')
        end
        return
    end
    local itemAmountRecieved = math.random(1, maxRecieved)

    if not isClose(src, 'turnIn') then return end

    repeat
        Wait(1)
        local item = Recieve[math.random(1, #Recieve)]
        local itemAmount = math.random(item.min, item.max)
        itemAmountRecieved = itemAmountRecieved - 1
        getItem(src, item.item, itemAmount)
    until itemAmountRecieved == 0

    local luckyChance = math.random(1, 100)
    if luckyChance <= LuckyItemChance then 
        Player.Functions.AddItem(luckyItem, 1)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[luckyItem], 'add', 1)
    end
end)

RegisterNetEvent('qb-recyclejob:server:sellItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isClose(src, 'sell') then return end
    if not Sales[item] then return end
    if Config.SellMaterials then
        sellMaterials(src, item, amount)
    end
end)
