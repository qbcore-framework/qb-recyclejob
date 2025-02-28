local QBCore = exports['qb-core']:GetCoreObject()
local carryPackage = nil
local packageCoords = nil
local onDuty = false
local isBusy = false
local inZone = {
    ['pickupTarget'] = false,
    ['enterLocation'] = false,
    ['exitLocation'] = false,
    ['dutyLocation'] = false,
    ['targetCrate'] = false,
    ['turnIn'] = false,
    ['sellPed'] = false,
}
local props = {}

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs (props) do
            DeleteObject(v)
        end
        if carryPackage then
            DeleteObject(carryPackage)
        end
        if packageCoords then
            SetEntityDrawOutline(props[packageCoords], false)
        end
    end
end)

local function DrawPackageLocationBlip()
    if not Config.DrawPackageLocationBlip then return end
    SetEntityDrawOutline(props[packageCoords], true)
    SetEntityDrawOutlineColor(props[packageCoords], 15,20,60)
end

local function GetRandomPackage()
    packageCoords = math.random(1, #Config.PickupLocations)
    DrawPackageLocationBlip()
end

local function PickupPackage()
    local pos = GetEntityCoords(PlayerPedId(), true)
    RequestAnimDict('anim@heists@box_carry@')
    while (not HasAnimDictLoaded('anim@heists@box_carry@')) do
        Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
    RequestModel(Config.PickupBoxModel)
    while not HasModelLoaded(Config.PickupBoxModel) do
        Wait(0)
    end
    local object = CreateObject(Config.PickupBoxModel, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end


local function DropPackage()
    ClearPedTasks(PlayerPedId())
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
end

local function SetLocationBlip()
    local RecycleBlip = AddBlipForCoord(Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z)
    SetBlipSprite(RecycleBlip, 365)
    SetBlipColour(RecycleBlip, 2)
    SetBlipScale(RecycleBlip, 0.8)
    SetBlipAsShortRange(RecycleBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Recycle Center')
    EndTextCommandSetBlipName(RecycleBlip)
end

SetLocationBlip()

local function EnterLocation()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(PlayerPedId(), Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z)
    DoScreenFadeIn(500)
end

local function ExitLocation()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(PlayerPedId(), Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z + 1)
    DoScreenFadeIn(500)

    onDuty = false

    if carryPackage then
        DropPackage()
    end
end

local function toggleDuty()
    if onDuty then
        QBCore.Functions.Notify(Lang:t('text.clock_out'), 'success')
        onDuty = false
        if packageCoords then
            SetEntityDrawOutline(props[packageCoords], false)
            packageCoords = nil
        end
    else
        QBCore.Functions.Notify(Lang:t('text.clock_in'), 'success')
        onDuty = true
        GetRandomPackage()
    end
end

local function pickUp()
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
        SetEntityDrawOutline(props[packageCoords], false)
        packageCoords = nil
        PickupPackage()
    end, function()
        isBusy = false
    end)

end

local function handInPackage()
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
        local menu = {}
        if data == false then QBCore.Functions.Notify(Lang:t('error.too_far_to_sell') 'error') return end
        for k, v in pairs (data) do
            if QBCore.Functions.HasItem(k) then
                menu[#menu+1] = {
                    header = QBCore.Shared.Items[k].label,
                    txt = Lang:t('text.price', {price = v}),
                    icon = "nui://qb-inventory/html/images/" .. QBCore.Shared.Items[k].name .. ".png",
                    action = function()
                        local dialog = exports['qb-input']:ShowInput({
                            header = Lang:t('text.sell') .. ' ' ..  QBCore.Shared.Items[k].label,
                            submitText = Lang:t('text.sell') ,
                            inputs = {
                                {
                                    text = Lang:t('text.amount'),
                                    header = Lang:t('text.amount'),
                                    type = "number",
                                    name = "amount",
                                },
                            }
                        })
                        if not dialog and dialog.amount then return end
                        TriggerServerEvent('qb-recyclejob:server:sellItem', k, tonumber(dialog.amount))
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

local function Start()
    if Config.SellMaterials then 
        RequestModel(GetHashKey('s_m_m_dockwork_01'))
        while not HasModelLoaded(GetHashKey('s_m_m_dockwork_01')) do
            Wait(0)
        end
        local loc = Config.SellPed
        local ped = CreatePed(4, GetHashKey('s_m_m_dockwork_01'), loc.x, loc.y, loc.z, loc.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if Config.UseTarget then 
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = 'fas fa-dollar-sign',
                        label = Lang:t('text.sell_materials'),
                        action = function()
                            sellMaterials()
                        end
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
                if isPointInside then
                    inZone['sellPed'] = true
                    exports['qb-core']:DrawText(Lang:t('text.point_sell_materials'), 'left')
                else
                    inZone['sellPed'] = false
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
    for k, v in pairs (Config.PickupLocations) do
        RequestModel(Config.WarehouseObjects[v.model])
        while not HasModelLoaded(Config.WarehouseObjects[v.model]) do
            Wait(0)
        end
        props[k] = CreateObject(Config.WarehouseObjects[v.model], v.loc.x, v.loc.y, v.loc.z, false, true, true)
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
                            if packageCoords == k then 
                                if isBusy == false then 
                                    return true
                                end
                            end
                        end,
                    },
                },
                distance = 1.5
            })
        else
            local zones = {}
            zones[k] = BoxZone:Create(v.loc, 4, 2.0, {
                name = zones[k],
                heading = v.loc.w + 20,
                minZ = v.loc.z - 1.0,
                maxZ = v.loc.z + 2.0,
                debugPoly = false
            })
            zones[k]:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    if k == packageCoords then
                       inZone['targetCrate'] = true
                        exports['qb-core']:DrawText(Lang:t('text.point_get_package'), 'left')
                    end
                else
                    inZone['targetCrate'] = false
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
    if Config.UseTarget then
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
                    action = function()
                        EnterLocation()
                    end,
                },
            },
            distance = 1.0
        })
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
                    action = function()
                        ExitLocation()
                    end,
                },
            },
            distance = 1.0
        })
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
                    action = function()
                        toggleDuty()
                    end,
                },
            },
            distance = 1.0
        })
        exports['qb-target']:AddBoxZone('recycleDrop', vector3(Config.DropLocation.x, Config.DropLocation.y, Config.DropLocation.z), 4, 1.5, {
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
                    action = function()
                        handInPackage()
                    end,
                    canInteract = function()
                        if carryPackage then
                            return true
                        end
                    end,
                },
            },
            distance = 1.5
        })
    else
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
        local dutyZone = BoxZone:Create(vector3(Config.DutyLocation.x, Config.DutyLocation.y, Config.DutyLocation.z-1), 2.0, 1.5, {
            name = 'dutyLocation',
            heading = 180.0,
            minZ = Config.DutyLocation.z - 2.0,
            maxZ = Config.DutyLocation.z + 1.0,
            debugPoly = false
        })
        local turnIn = BoxZone:Create(vector3(Config.DropLocation.x, Config.DropLocation.y, Config.DropLocation.z), 2.0, 1.5, {
            name = 'recycleDrop',
            heading = 180.0,
            minZ = Config.DropLocation.z - 1.0,
            maxZ = Config.DropLocation.z + 2.0,
            debugPoly = false
        })
        enterZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_enter_warehouse'), 'left')
                inZone['enterLocation'] = isPointInside
            else
                exports['qb-core']:HideText()
                inZone['enterLocation'] = isPointInside
            end
        end)
        exitZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_exit_warehouse'), 'left')
                inZone['exitLocation'] = isPointInside
            else
                exports['qb-core']:HideText()
                inZone['exitLocation'] = isPointInside
            end
        end)
        dutyZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText(Lang:t('text.point_toggle_duty'), 'left')
                inZone['dutyLocation'] = isPointInside
            else
                exports['qb-core']:HideText()
                inZone['dutyLocation'] = isPointInside
            end
        end)
        turnIn:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if carryPackage then
                    inZone['turnIn'] = isPointInside
                    exports['qb-core']:DrawText(Lang:t('text.point_hand_in_package'), 'left')
                end
            else
                exports['qb-core']:HideText()
                inZone['turnIn'] = isPointInside
            end
        end)

        while true do
            if inZone['enterLocation'] then
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['enterLocation']
                if inZone['enterLocation'] then
                    EnterLocation()
                end
            end
            if inZone['exitLocation'] then
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['exitLocation']
                if inZone['exitLocation'] then
                    ExitLocation()
                end
            end
            if inZone['dutyLocation'] then
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['dutyLocation']
                if inZone['dutyLocation'] then
                    toggleDuty()
                end
            end
            if inZone['targetCrate'] then
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['targetCrate']
                exports['qb-core']:HideText()
                if inZone['targetCrate'] then
                    if not isBusy then 
                        pickUp()
                    end
                end
            end
            if inZone['turnIn'] then
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['turnIn'] or not carryPackage
                if inZone['turnIn'] then
                    if carryPackage then
                        handInPackage()
                    end
                end
            end
            if inZone['sellPed'] then 
                repeat
                    Wait(1)
                until IsControlJustReleased(0, 38) or not inZone['sellPed']
                if inZone['sellPed'] then
                    sellMaterials()
                end
            end
        Wait(100)
        end
    end
end

Wait(100)
Start()