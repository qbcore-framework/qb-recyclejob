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
local dropLocation = vector4(1048.224, -3097.071, -38.999, 274.810)
local LuckyItemChance = 20 -- 20% chance to get a lucky item
local uhohs = {}

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

local function isClose(source)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - vector3(dropLocation.x, dropLocation.y, dropLocation.z))

    if distance < 5.0 then
        return true
    else
        return false
    end
end

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isClose(src) then
        uhohs[src] = uhohs[src] + 1 or 0
        if uhohs[src] > 3 then 
            exploitBan(src, 'Exploiting distance on qb-recyclejob')
        end
        return
    end
    local itemAmountRecieved = math.random(1, maxRecieved)
    repeat
        Wait(1)
        local item = Recieve[math.random(1, #Recieve)]
        local itemAmount = math.random(item.min, item.max)
        itemAmountRecieved = itemAmountRecieved - 1
        Player.Functions.AddItem(item.item, itemAmount)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add', itemAmount)
    until itemAmountRecieved == 0

    local luckyChance = math.random(1, 100)
    if luckyChance <= LuckyItemChance then 
        Player.Functions.AddItem(luckyItem, 1)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[luckyItem], 'add', 1)
    end
end)
