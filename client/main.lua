local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- LOCAL VARIABLES
-- ========================================
local carryPackage = nil
local packageCoords = nil
local onDuty = false
local isBusy = false
local props = {}
local playerRankingData = nil

local inZone = {
    pickupTarget = false,
    enterLocation = false,
    exitLocation = false,
    dutyLocation = false,
    targetCrate = false,
    turnIn = false,
    sellPed = false,
}

-- ========================================
-- RESOURCE CLEANUP
-- ========================================
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, prop in pairs(props) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end

    if carryPackage and DoesEntityExist(carryPackage) then
        DeleteObject(carryPackage)
    end

    if packageCoords and props[packageCoords] and DoesEntityExist(props[packageCoords]) then
        SetEntityDrawOutline(props[packageCoords], false)
    end

    -- Hide ranking UI
    SendNUIMessage({ action = 'hide' })
end)

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 1000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasAnimDictLoaded(dict)
end

local function LoadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    if HasModelLoaded(hash) then return true end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 1000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasModelLoaded(hash)
end

-- ========================================
-- RANKING UI FUNCTIONS
-- ========================================

local function UpdateRankingUI()
    if not Config.Ranking.Enabled or not onDuty then return end

    QBCore.Functions.TriggerCallback('qb-recyclejob:server:getPlayerRanking', function(data)
        if data then
            playerRankingData = data
            SendNUIMessage({
                action = 'updatePlayer',
                level = data.level,
                currentXP = data.current_xp,
                xpForNextLevel = data.xp_for_next_level,
                totalDeliveries = data.total_deliveries,
                rank = data.rank or 0
            })
        end
    end)

    QBCore.Functions.TriggerCallback('qb-recyclejob:server:getTopRankings', function(rankings)
        if rankings then
            SendNUIMessage({
                action = 'updateRankings',
                rankings = rankings
            })
        end
    end)
end

local function ShowRankingUI()
    if not Config.Ranking.Enabled then return end
    SendNUIMessage({ action = 'show' })
    UpdateRankingUI()
end

local function HideRankingUI()
    SendNUIMessage({ action = 'hide' })
end

-- ========================================
-- PACKAGE FUNCTIONS
-- ========================================

local function DrawPackageLocationBlip()
    if not Config.DrawPackageLocationBlip then return end
    if not packageCoords or not props[packageCoords] then return end
    if DoesEntityExist(props[packageCoords]) then
        SetEntityDrawOutline(props[packageCoords], true)
        SetEntityDrawOutlineColor(15, 20, 60, 255)
    end
end

local function GetRandomPackage()
    packageCoords = math.random(1, #Config.PickupLocations)
    DrawPackageLocationBlip()
end

local function PickupPackage()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if not LoadAnimDict('anim@heists@box_carry@') then return end
    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)

    if not LoadModel(Config.PickupBoxModel) then return end
    local object = CreateObject(Config.PickupBoxModel, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end

local function DropPackage()
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    if carryPackage and DoesEntityExist(carryPackage) then
        DetachEntity(carryPackage, true, true)
        DeleteObject(carryPackage)
    end
    carryPackage = nil
end

-- ========================================
-- LOCATION FUNCTIONS
-- ========================================

local function SetLocationBlip()
    local blip = AddBlipForCoord(Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z)
    SetBlipSprite(blip, 365)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Recycle Center')
    EndTextCommandSetBlipName(blip)
end

local function EnterLocation()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z)
    DoScreenFadeIn(500)
end

local function ExitLocation()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z + 1)
    DoScreenFadeIn(500)

    onDuty = false
    HideRankingUI()

    if carryPackage then
        DropPackage()
    end
end

-- ========================================
-- DUTY FUNCTIONS
-- ========================================

local function toggleDuty()
    if onDuty then
        QBCore.Functions.Notify(Lang:t('text.clock_out'), 'success')
        onDuty = false
        HideRankingUI()

        if packageCoords and props[packageCoords] and DoesEntityExist(props[packageCoords]) then
            SetEntityDrawOutline(props[packageCoords], false)
        end
        packageCoords = nil
    else
        QBCore.Functions.Notify(Lang:t('text.clock_in'), 'success')
        onDuty = true
        GetRandomPackage()
        ShowRankingUI()
    end
end

-- ========================================
-- ACTION FUNCTIONS
-- ========================================

local function pickUp()
    if isBusy then return end
    isBusy = true

    QBCore.Functions.Progressbar('pickup_reycle_package', Lang:t('text.picking_up_the_package'), Config.PickupActionDuration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = 'mp_car_bomb',
        anim = 'car_bomb_mechanic',
        flags = 16
    }, {}, {}, function()
        isBusy = false
        if packageCoords and props[packageCoords] and DoesEntityExist(props[packageCoords]) then
            SetEntityDrawOutline(props[packageCoords], false)
        end
        packageCoords = nil
        PickupPackage()
    end, function()
        isBusy = false
    end)
end

local function handInPackage()
    if not carryPackage then return end

    DropPackage()
    QBCore.Functions.Progressbar('deliver_reycle_package', Lang:t('text.unpacking_the_package'), Config.DeliveryActionDuration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = 'mp_car_bomb',
        anim = 'car_bomb_mechanic',
        flags = 16
    }, {}, {}, function()
        TriggerServerEvent('qb-recyclejob:server:getItem')
        GetRandomPackage()
    end)
end

local function sellMaterials()
    QBCore.Functions.TriggerCallback('qb-recyclejob:server:getPriceList', function(data)
        if data == false then
            QBCore.Functions.Notify(Lang:t('error.too_far_to_sell'), 'error')
            return
        end

        local menu = {}
        for k, v in pairs(data) do
            if QBCore.Functions.HasItem(k) then
                menu[#menu + 1] = {
                    header = QBCore.Shared.Items[k].label,
                    txt = Lang:t('text.price', {price = v}),
                    icon = "nui://qb-inventory/html/images/" .. QBCore.Shared.Items[k].name .. ".png",
                    action = function()
                        local dialog = exports['qb-input']:ShowInput({
                            header = Lang:t('text.sell') .. ' ' .. QBCore.Shared.Items[k].label,
                            submitText = Lang:t('text.sell'),
                            inputs = {
                                {
                                    text = Lang:t('text.amount'),
                                    header = Lang:t('text.amount'),
                                    type = "number",
                                    name = "amount",
                                },
                            }
                        })
                        if dialog and dialog.amount then
                            TriggerServerEvent('qb-recyclejob:server:sellItem', k, tonumber(dialog.amount))
                        end
                    end
                }
            end
        end

        if #menu == 0 then
            QBCore.Functions.Notify(Lang:t('error.nothing_to_sell'), 'error')
            return
        end

        exports['qb-menu']:openMenu(menu)
    end)
end

-- ========================================
-- CLIENT EVENTS (RANKING)
-- ========================================

RegisterNetEvent('qb-recyclejob:client:xpGain', function(xpGained, data)
    if not Config.Ranking.Enabled then return end

    playerRankingData = data
    SendNUIMessage({
        action = 'xpGain',
        xpGained = xpGained,
        level = data.level,
        currentXP = data.current_xp,
        xpForNextLevel = data.xp_for_next_level,
        totalDeliveries = data.total_deliveries
    })

    QBCore.Functions.Notify(Lang:t('success.xp_gained', {xp = xpGained}), 'success')
end)

RegisterNetEvent('qb-recyclejob:client:levelUp', function(newLevel, reward)
    if not Config.Ranking.Enabled then return end

    SendNUIMessage({
        action = 'levelUp',
        level = newLevel
    })

    QBCore.Functions.Notify(Lang:t('success.level_up', {level = newLevel, reward = reward}), 'success')
    UpdateRankingUI()
end)

-- ========================================
-- MAIN INITIALIZATION
-- ========================================

local function Start()
    -- Create sell ped if enabled
    if Config.SellMaterials then
        local pedModel = 's_m_m_dockwork_01'
        if not LoadModel(pedModel) then return end

        local loc = Config.SellPed
        local ped = CreatePed(4, GetHashKey(pedModel), loc.x, loc.y, loc.z, loc.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if Config.UseTarget then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = 'fas fa-dollar-sign',
                        label = Lang:t('text.sell_materials'),
                        action = sellMaterials
                    },
                },
                distance = 1.5
            })
        else
            local sellZone = BoxZone:Create(vector3(loc.x, loc.y, loc.z), 2.0, 1.5, {
                name = 'sellPed',
                heading = 180.0,
                minZ = loc.z - 1.0,
                maxZ = loc.z + 2.0,
                debugPoly = false
            })
            sellZone:onPlayerInOut(function(isPointInside)
                inZone.sellPed = isPointInside
                if isPointInside then
                    exports['qb-core']:DrawText(Lang:t('text.point_sell_materials'), 'left')
                else
                    exports['qb-core']:HideText()
                end
            end)
        end
    end

    -- Create warehouse objects and pickup zones
    for k, v in pairs(Config.PickupLocations) do
        local modelName = Config.WarehouseObjects[v.model]
        if LoadModel(modelName) then
            props[k] = CreateObject(modelName, v.loc.x, v.loc.y, v.loc.z, false, true, true)
            PlaceObjectOnGroundProperly(props[k])
            FreezeEntityPosition(props[k], true)

            if Config.UseTarget then
                exports['qb-target']:AddTargetEntity(props[k], {
                    options = {
                        {
                            type = 'client',
                            label = Lang:t('text.get_package'),
                            icon = 'fas fa-box',
                            action = function()
                                if not isBusy then
                                    pickUp()
                                end
                            end,
                            canInteract = function()
                                return packageCoords == k and not isBusy
                            end,
                        },
                    },
                    distance = 1.5
                })
            else
                local zone = BoxZone:Create(v.loc, 4, 2.0, {
                    name = 'pickupZone_' .. k,
                    heading = v.loc.w + 20,
                    minZ = v.loc.z - 1.0,
                    maxZ = v.loc.z + 2.0,
                    debugPoly = false
                })
                zone:onPlayerInOut(function(isPointInside)
                    if isPointInside and k == packageCoords then
                        inZone.targetCrate = true
                        exports['qb-core']:DrawText(Lang:t('text.point_get_package'), 'left')
                    elseif not isPointInside and inZone.targetCrate then
                        inZone.targetCrate = false
                        exports['qb-core']:HideText()
                    end
                end)
            end
        end
    end

    -- Setup target/polyzone interactions
    if Config.UseTarget then
        -- Enter location zone
        exports['qb-target']:AddBoxZone('enterLocation', vector3(Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z), 4, 1.5, {
            name = 'enterLocation',
            heading = 44.0,
            minZ = Config.OutsideLocation.z - 1.0,
            maxZ = Config.OutsideLocation.z + 2.0,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    label = Lang:t('text.enter_warehouse'),
                    action = EnterLocation,
                },
            },
            distance = 1.0
        })

        -- Exit location zone
        exports['qb-target']:AddBoxZone('exitLocation', vector3(Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z), 4, 1.5, {
            name = 'exitLocation',
            heading = 44.0,
            minZ = Config.InsideLocation.z - 1.0,
            maxZ = Config.InsideLocation.z + 2.0,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    label = Lang:t('text.exit_warehouse'),
                    action = ExitLocation,
                },
            },
            distance = 1.0
        })

        -- Duty location zone
        exports['qb-target']:AddBoxZone('dutyLocation', vector3(Config.DutyLocation.x, Config.DutyLocation.y, Config.DutyLocation.z), 4, 1.5, {
            name = 'dutyLocation',
            heading = 44.0,
            minZ = Config.DutyLocation.z - 1.0,
            maxZ = Config.DutyLocation.z + 2.0,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    label = Lang:t('text.toggle_duty'),
                    action = toggleDuty,
                },
            },
            distance = 1.0
        })

        -- Drop location zone (expanded size)
        local dropSize = Config.DropZoneSize or { length = 6.0, width = 4.0 }
        exports['qb-target']:AddBoxZone('recycleDrop', vector3(Config.DropLocation.x, Config.DropLocation.y, Config.DropLocation.z), dropSize.length, dropSize.width, {
            name = 'recycleDrop',
            heading = 44.0,
            minZ = Config.DropLocation.z - 1.0,
            maxZ = Config.DropLocation.z + 2.0,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    label = Lang:t('text.hand_in_package'),
                    action = handInPackage,
                    canInteract = function()
                        return carryPackage ~= nil
                    end,
                },
            },
            distance = 2.0
        })
    else
        -- PolyZone mode setup
        local enterZone = BoxZone:Create(vector3(Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z), 4, 1.5, {
            name = 'enterLocation',
            heading = 133.0,
            minZ = Config.OutsideLocation.z - 1.0,
            maxZ = Config.OutsideLocation.z + 2.0,
            debugPoly = false
        })

        local exitZone = BoxZone:Create(vector3(Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z), 4, 1.5, {
            name = 'exitLocation',
            heading = 180.0,
            minZ = Config.InsideLocation.z - 1.0,
            maxZ = Config.InsideLocation.z + 2.0,
            debugPoly = false
        })

        local dutyZone = BoxZone:Create(vector3(Config.DutyLocation.x, Config.DutyLocation.y, Config.DutyLocation.z - 1), 2.0, 1.5, {
            name = 'dutyLocation',
            heading = 180.0,
            minZ = Config.DutyLocation.z - 2.0,
            maxZ = Config.DutyLocation.z + 1.0,
            debugPoly = false
        })

        -- Expanded drop zone
        local dropSize = Config.DropZoneSize or { length = 6.0, width = 4.0 }
        local turnInZone = BoxZone:Create(vector3(Config.DropLocation.x, Config.DropLocation.y, Config.DropLocation.z), dropSize.length, dropSize.width, {
            name = 'recycleDrop',
            heading = 180.0,
            minZ = Config.DropLocation.z - 1.0,
            maxZ = Config.DropLocation.z + 2.0,
            debugPoly = false
        })

        enterZone:onPlayerInOut(function(isPointInside)
            inZone.enterLocation = isPointInside
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_enter_warehouse'), 'left')
            else
                exports['qb-core']:HideText()
            end
        end)

        exitZone:onPlayerInOut(function(isPointInside)
            inZone.exitLocation = isPointInside
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_exit_warehouse'), 'left')
            else
                exports['qb-core']:HideText()
            end
        end)

        dutyZone:onPlayerInOut(function(isPointInside)
            inZone.dutyLocation = isPointInside
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_toggle_duty'), 'left')
            else
                exports['qb-core']:HideText()
            end
        end)

        turnInZone:onPlayerInOut(function(isPointInside)
            if isPointInside and carryPackage then
                inZone.turnIn = true
                exports['qb-core']:DrawText(Lang:t('text.point_hand_in_package'), 'left')
            else
                inZone.turnIn = false
                if not isPointInside then
                    exports['qb-core']:HideText()
                end
            end
        end)

        -- Optimized interaction loop using CreateThread
        CreateThread(function()
            while true do
                local sleep = 100

                if inZone.enterLocation then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        EnterLocation()
                    end
                elseif inZone.exitLocation then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        ExitLocation()
                    end
                elseif inZone.dutyLocation then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        toggleDuty()
                    end
                elseif inZone.targetCrate then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        exports['qb-core']:HideText()
                        if not isBusy then
                            pickUp()
                        end
                    end
                elseif inZone.turnIn and carryPackage then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        handInPackage()
                    end
                elseif inZone.sellPed then
                    sleep = 0
                    if IsControlJustReleased(0, 38) then
                        sellMaterials()
                    end
                end

                Wait(sleep)
            end
        end)
    end
end

-- ========================================
-- INITIALIZATION
-- ========================================

SetLocationBlip()
CreateThread(function()
    Wait(100)
    Start()
end)

-- Periodic ranking UI update while on duty
CreateThread(function()
    while true do
        Wait(30000) -- Update every 30 seconds
        if onDuty and Config.Ranking.Enabled then
            UpdateRankingUI()
        end
    end
end)
