local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- CONFIGURATION
-- ========================================
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

local luckyItem = 'cryptostick'
local maxRecieved = 5
local dropLocation = Config.DropLocation
local LuckyItemChance = 20
local uhohs = {}
local Sales, Stock, salesLoc = {}, {}, Config.SellPed

-- ========================================
-- RANKING SYSTEM CACHE
-- ========================================
local RankingCache = {
    topRankings = {},
    lastUpdate = 0,
    playerData = {}, -- Per-player cache: { [citizenid] = { level, xp, lastUpdate } }
}

-- ========================================
-- INITIALIZE SALES AND STOCK
-- ========================================
if Config.SellMaterials then
    Sales = {
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
    Stock = {
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

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function exploitBan(id, reason)
    local license = QBCore.Functions.GetIdentifier(id, 'license')
    local discord = QBCore.Functions.GetIdentifier(id, 'discord')
    local ip = QBCore.Functions.GetIdentifier(id, 'ip')

    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(id),
        license,
        discord,
        ip,
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
    if not playerPed or playerPed == 0 then return false end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local cid = Player.PlayerData.citizenid
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords, maxDistance

    if loc == 'turnIn' then
        targetCoords = vector3(dropLocation.x, dropLocation.y, dropLocation.z)
        maxDistance = Config.DropDistanceCheck or 8.0
    elseif loc == 'sell' then
        targetCoords = vector3(salesLoc.x, salesLoc.y, salesLoc.z)
        maxDistance = 5.0
    else
        return false
    end

    local distance = #(playerCoords - targetCoords)

    if distance < maxDistance then
        return true
    else
        uhohs[cid] = (uhohs[cid] or 0) + 1
        if uhohs[cid] >= 3 then
            exploitBan(source, 'Exploiting distance on qb-recyclejob')
        end
        return false
    end
end

-- ========================================
-- RANKING SYSTEM FUNCTIONS
-- ========================================

-- Calculate XP required for a specific level
-- Uses exponential growth that caps at DifficultyCapLevel
local function CalculateXPForLevel(level)
    if level <= 1 then return 0 end

    local baseXP = Config.Ranking.BaseXP
    local multiplier = Config.Ranking.XPMultiplier
    local capLevel = Config.Ranking.DifficultyCapLevel

    -- Use capped level for difficulty calculation
    local effectiveLevel = math.min(level - 1, capLevel)

    -- Exponential formula with cap
    -- After cap level, XP requirement stays constant
    local xpRequired = math.floor(baseXP * (multiplier ^ effectiveLevel))

    return xpRequired
end

-- Calculate total XP needed to reach a level from level 1
local function CalculateTotalXPForLevel(level)
    if level <= 1 then return 0 end

    local totalXP = 0
    for i = 2, level do
        totalXP = totalXP + CalculateXPForLevel(i)
    end
    return totalXP
end

-- Calculate level from total XP
local function CalculateLevelFromTotalXP(totalXP)
    local level = 1
    local xpAccumulated = 0

    while level < Config.Ranking.MaxLevel do
        local xpForNext = CalculateXPForLevel(level + 1)
        if xpAccumulated + xpForNext > totalXP then
            break
        end
        xpAccumulated = xpAccumulated + xpForNext
        level = level + 1
    end

    return level, totalXP - xpAccumulated
end

-- Get player ranking data from database or cache
local function GetPlayerRankingData(citizenid, forceRefresh)
    local currentTime = os.time()
    local cachedData = RankingCache.playerData[citizenid]

    -- Return cached data if valid and not forcing refresh
    if cachedData and not forceRefresh then
        local cooldown = Config.Ranking.PlayerUpdateCooldown or 5
        if (currentTime - cachedData.lastUpdate) < cooldown then
            return cachedData
        end
    end

    -- Fetch from database
    local result = MySQL.single.await('SELECT * FROM recyclejob_ranking WHERE citizenid = ?', {citizenid})

    if result then
        local data = {
            citizenid = result.citizenid,
            name = result.name,
            level = result.level,
            current_xp = result.current_xp,
            total_xp = result.total_xp,
            total_deliveries = result.total_deliveries,
            lastUpdate = currentTime
        }
        RankingCache.playerData[citizenid] = data
        return data
    end

    return nil
end

-- Create or update player ranking data
local function UpdatePlayerRankingData(citizenid, name, addXP, isDelivery)
    if not Config.Ranking.Enabled then return nil end

    local currentData = GetPlayerRankingData(citizenid, true)
    local newTotalXP, newDeliveries

    if currentData then
        newTotalXP = currentData.total_xp + addXP
        newDeliveries = currentData.total_deliveries + (isDelivery and 1 or 0)
    else
        newTotalXP = addXP
        newDeliveries = isDelivery and 1 or 0
    end

    local newLevel, newCurrentXP = CalculateLevelFromTotalXP(newTotalXP)
    local xpForNextLevel = CalculateXPForLevel(newLevel + 1)
    local leveledUp = currentData and newLevel > currentData.level

    -- Upsert to database
    MySQL.insert.await([[
        INSERT INTO recyclejob_ranking (citizenid, name, level, current_xp, total_xp, total_deliveries)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            level = VALUES(level),
            current_xp = VALUES(current_xp),
            total_xp = VALUES(total_xp),
            total_deliveries = VALUES(total_deliveries)
    ]], {citizenid, name, newLevel, newCurrentXP, newTotalXP, newDeliveries})

    -- Update cache
    local currentTime = os.time()
    RankingCache.playerData[citizenid] = {
        citizenid = citizenid,
        name = name,
        level = newLevel,
        current_xp = newCurrentXP,
        total_xp = newTotalXP,
        total_deliveries = newDeliveries,
        lastUpdate = currentTime
    }

    -- Invalidate top rankings cache if player might be in top
    RankingCache.lastUpdate = 0

    return {
        level = newLevel,
        current_xp = newCurrentXP,
        total_xp = newTotalXP,
        xp_for_next_level = xpForNextLevel,
        total_deliveries = newDeliveries,
        leveled_up = leveledUp,
        old_level = currentData and currentData.level or 0
    }
end

-- Get top rankings (cached for performance)
local function GetTopRankings()
    if not Config.Ranking.Enabled then return {} end

    local currentTime = os.time()
    local cacheInterval = Config.Ranking.RankingCacheInterval or 60

    -- Return cached data if valid
    if (currentTime - RankingCache.lastUpdate) < cacheInterval and #RankingCache.topRankings > 0 then
        return RankingCache.topRankings
    end

    -- Fetch from database
    local limit = Config.Ranking.TopRankingsCount or 10
    local results = MySQL.query.await([[
        SELECT citizenid, name, level, total_xp, total_deliveries
        FROM recyclejob_ranking
        ORDER BY total_xp DESC, total_deliveries DESC
        LIMIT ?
    ]], {limit})

    if results then
        RankingCache.topRankings = results
        RankingCache.lastUpdate = currentTime
    end

    return RankingCache.topRankings or {}
end

-- Get player's rank position
local function GetPlayerRankPosition(citizenid)
    if not Config.Ranking.Enabled then return 0 end

    local result = MySQL.single.await([[
        SELECT COUNT(*) + 1 as rank
        FROM recyclejob_ranking
        WHERE total_xp > (SELECT COALESCE(total_xp, 0) FROM recyclejob_ranking WHERE citizenid = ?)
    ]], {citizenid})

    return result and result.rank or 0
end

-- ========================================
-- STOCK MANAGEMENT FUNCTIONS
-- ========================================

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
    if Stock[item] and Stock[item] >= amount then
        return true
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.out_of_stock', {item = item}), 'error')
        return false
    end
end

local function sellMaterials(src, item, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

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
    end
end

local function getItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if Config.LimitedMaterials then
        if not checkStock(source, item, amount) then return end
    end

    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)

    if Config.LimitedMaterials then
        adjustStock(item, 'remove', amount)
    end
end

-- ========================================
-- CALLBACKS
-- ========================================

QBCore.Functions.CreateCallback('qb-recyclejob:server:getPriceList', function(source, cb)
    if not isClose(source, 'sell') then
        cb(false)
        return
    end
    cb(Sales)
end)

-- Get player's ranking data
QBCore.Functions.CreateCallback('qb-recyclejob:server:getPlayerRanking', function(source, cb)
    if not Config.Ranking.Enabled then
        cb(nil)
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb(nil)
        return
    end

    local citizenid = Player.PlayerData.citizenid
    local data = GetPlayerRankingData(citizenid)

    if data then
        data.rank = GetPlayerRankPosition(citizenid)
        data.xp_for_next_level = CalculateXPForLevel(data.level + 1)
        cb(data)
    else
        -- Return default data for new players
        cb({
            level = 1,
            current_xp = 0,
            total_xp = 0,
            total_deliveries = 0,
            rank = 0,
            xp_for_next_level = CalculateXPForLevel(2)
        })
    end
end)

-- Get top rankings
QBCore.Functions.CreateCallback('qb-recyclejob:server:getTopRankings', function(source, cb)
    if not Config.Ranking.Enabled then
        cb({})
        return
    end
    cb(GetTopRankings())
end)

-- ========================================
-- EVENTS
-- ========================================

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Distance check
    if not isClose(src, 'turnIn') then
        local cid = Player.PlayerData.citizenid
        uhohs[cid] = (uhohs[cid] or 0) + 1
        if uhohs[cid] >= 3 then
            exploitBan(src, 'Exploiting distance on qb-recyclejob')
        end
        return
    end

    -- Give random items
    local itemAmountRecieved = math.random(1, maxRecieved)
    local gotLucky = false

    for _ = 1, itemAmountRecieved do
        local item = Recieve[math.random(1, #Recieve)]
        local itemAmount = math.random(item.min, item.max)
        getItem(src, item.item, itemAmount)
    end

    -- Lucky item chance
    local luckyChance = math.random(1, 100)
    if luckyChance <= LuckyItemChance then
        Player.Functions.AddItem(luckyItem, 1)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[luckyItem], 'add', 1)
        gotLucky = true
    end

    -- Update ranking
    if Config.Ranking.Enabled then
        local citizenid = Player.PlayerData.citizenid
        local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

        -- Calculate XP earned
        local baseXP = math.random(Config.Ranking.XPPerDelivery.min, Config.Ranking.XPPerDelivery.max)
        local bonusXP = gotLucky and Config.Ranking.LuckyItemBonusXP or 0
        local totalXP = baseXP + bonusXP

        -- Update player data and get result
        local result = UpdatePlayerRankingData(citizenid, playerName, totalXP, true)

        if result then
            -- Notify client about XP gain
            TriggerClientEvent('qb-recyclejob:client:xpGain', src, totalXP, result)

            -- Handle level up
            if result.leveled_up then
                local reward = math.floor(Config.Ranking.LevelUpReward * (Config.Ranking.LevelUpRewardMultiplier ^ (result.level - 1)))
                Player.Functions.AddMoney('cash', reward)
                TriggerClientEvent('qb-recyclejob:client:levelUp', src, result.level, reward)
            end
        end
    end
end)

RegisterNetEvent('qb-recyclejob:server:sellItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not isClose(src, 'sell') then return end
    if not Sales[item] then return end

    if Config.SellMaterials then
        sellMaterials(src, item, amount)
    end
end)

-- ========================================
-- RESOURCE EVENTS
-- ========================================

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    -- Ensure database table exists
    if Config.Ranking.Enabled then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `recyclejob_ranking` (
                `id` INT(11) NOT NULL AUTO_INCREMENT,
                `citizenid` VARCHAR(50) NOT NULL,
                `name` VARCHAR(100) NOT NULL DEFAULT 'Unknown',
                `level` INT(11) NOT NULL DEFAULT 1,
                `current_xp` BIGINT(20) NOT NULL DEFAULT 0,
                `total_xp` BIGINT(20) NOT NULL DEFAULT 0,
                `total_deliveries` INT(11) NOT NULL DEFAULT 0,
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `citizenid` (`citizenid`),
                INDEX `idx_level` (`level` DESC),
                INDEX `idx_total_xp` (`total_xp` DESC),
                INDEX `idx_total_deliveries` (`total_deliveries` DESC)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
        print('[qb-recyclejob] Ranking system initialized')
    end
end)
