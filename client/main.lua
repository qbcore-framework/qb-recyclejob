local QBCore = exports['qb-core']:GetCoreObject()
local carryPackage = nil
local packageCoords = nil
local onDuty = false
local isInside = false

-- zone check

local entranceTargetID = 'entranceTarget'
local isInsideEntranceZone = false
local entranceZone = nil

local exitTargetID = 'exitTarget'
local isInsideExitZone = false
local exitZone = nil

local deliveryTargetID = 'deliveryTarget'
local isInsideDeliveryZone = false
local deliveryZone = nil

local dutyTargetID = 'dutyTarget'
local isInsideDutyZone = false
local dutyZone = nil

local pickupTargetID = 'pickupTarget'
local isInsidePickupZone = false
local pickupZone = nil

-- Functions

local function RegisterEntranceTarget()
  entranceZone =
    BoxZone:Create(
    vector3(Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z),
    1,
    4,
    {
      name = entranceTargetID,
      heading = 44.0,
      minZ = Config.OutsideLocation.z - 1.0,
      maxZ = Config.OutsideLocation.z + 2.0,
      debugPoly = false
    }
  )

  entranceZone:onPlayerInOut(
    function(isPointInside)
      if isPointInside then
        exports['qb-core']:DrawText('[E] Enter Warehouse', 'left')
      else
        exports['qb-core']:HideText()
      end

      isInsideEntranceZone = isPointInside
    end
  )
end

local function RegisterExitTarget()
  exitZone =
    BoxZone:Create(
    vector3(Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z),
    1,
    4,
    {
      name = exitTargetID,
      heading = 270,
      minZ = Config.InsideLocation.z - 1.0,
      maxZ = Config.InsideLocation.z + 2.0,
      debugPoly = false
    }
  )

  exitZone:onPlayerInOut(
    function(isPointInside)
      if isPointInside then
        exports['qb-core']:DrawText('[E] Exit Warehouse', 'left')
      else
        exports['qb-core']:HideText()
      end

      isInsideExitZone = isPointInside
    end
  )
end

local function RegisterDutyTarget()
  dutyZone =
    BoxZone:Create(
    vector3(Config.DutyLocation.x, Config.DutyLocation.y, Config.DutyLocation.z),
    1,
    1,
    {
      name = dutyTargetID,
      heading = 270,
      minZ = Config.DutyLocation.z - 2.0,
      maxZ = Config.DutyLocation.z + 1.0,
      debugPoly = false
    }
  )

  dutyZone:onPlayerInOut(
    function(isPointInside)
      local text = nil
      if onDuty then
        text = '[E] Clock Out'
      else
        text = '[E] Clock In'
      end

      if isPointInside then
        exports['qb-core']:DrawText(text, 'left')
      else
        exports['qb-core']:HideText()
      end

      isInsideDutyZone = isPointInside
    end
  )
end

local function RegisterDeliveyTarget()
  deliveryZone =
    BoxZone:Create(
    vector3(Config.DropLocation.x, Config.DropLocation.y, Config.DropLocation.z),
    1,
    1,
    {
      name = deliveryTargetID,
      heading = 270,
      minZ = Config.DropLocation.z - 2.0,
      maxZ = Config.DropLocation.z + 1.0,
      debugPoly = false
    }
  )

  deliveryZone:onPlayerInOut(
    function(isPointInside)
      if isPointInside and carryPackage then
        exports['qb-core']:DrawText('[E] Hand In Package', 'left')
      else
        exports['qb-core']:HideText()
      end

      isInsideDeliveryZone = isPointInside
    end
  )
end

local function DestoryInsideZones()
  if pickupZone then
    pickupZone:destroy()
    pickupZone = nil
  end

  if exitZone then
    exitZone:destroy()
    exitZone = nil
  end

  if dutyZone then
    dutyZone:destroy()
    dutyZone = nil
  end
end

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Wait(5)
  end
end

local function ScrapAnim()
  local time = 5
  loadAnimDict('mp_car_bomb')
  TaskPlayAnim(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, false, false, false)
  local openingDoor = true
  CreateThread(
    function()
      while openingDoor do
        TaskPlayAnim(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, 0, 0, 0)
        Wait(1000)
        time = time - 1
        if time <= 0 then
          openingDoor = false
          StopAnimTask(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
        end
      end
    end
  )
end

local function GetRandomPackage()
  packageCoords = Config.PickupLocations[math.random(1, #Config.PickupLocations)]
  RegisterPickupTarget(packageCoords)
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
  AddTextComponentString('Recycle Center')
  EndTextCommandSetBlipName(RecycleBlip)
end

local function buildInteriorDesign()
  for _, pickuploc in pairs(Config.PickupLocations) do
    local model = GetHashKey(Config.WarehouseObjects[math.random(1, #Config.WarehouseObjects)])
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end
    local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
  end
end

local function EnterLocation()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do
    Wait(10)
  end
  SetEntityCoords(PlayerPedId(), Config.InsideLocation.x, Config.InsideLocation.y, Config.InsideLocation.z)
  buildInteriorDesign()
  DoScreenFadeIn(500)

  isInside = true
  isInsidePickupZone = false
  isInsideExitZone = false
  isInsideDutyZone = false
  isInsideEntranceZone = false

  DestoryInsideZones()
  RegisterExitTarget()
  RegisterDutyTarget()
  RegisterDeliveyTarget()
end

local function ExitLocation()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do
    Wait(10)
  end
  SetEntityCoords(PlayerPedId(), Config.OutsideLocation.x, Config.OutsideLocation.y, Config.OutsideLocation.z + 1)
  DoScreenFadeIn(500)

  isInside = false
  onDuty = false
  isInsidePickupZone = false
  isInsideExitZone = false
  isInsideDutyZone = false
  isInsideEntranceZone = false

  DestoryInsideZones()

  if carryPackage then
    DropPackage()
  end
end

function RegisterPickupTarget(coords)
  pickupZone =
    BoxZone:Create(
    vector3(coords.x, coords.y, coords.z),
    4,
    1.5,
    {
      name = pickupTargetID,
      heading = coords.h,
      minZ = coords.z - 1.0,
      maxZ = coords.z + 2.0,
      debugPoly = false
    }
  )

  pickupZone:onPlayerInOut(
    function(isPointInside)
      if isPointInside then
        exports['qb-core']:DrawText('[E] Get Package', 'left')
      else
        exports['qb-core']:HideText()
      end

      isInsidePickupZone = isPointInside
    end
  )
end

-- Events

RegisterNetEvent(
  'qb-recyclejob:client:target:enterLocation',
  function()
    EnterLocation()
  end
)

RegisterNetEvent(
  'qb-recyclejob:client:target:exitLocation',
  function()
    ExitLocation()
  end
)

RegisterNetEvent(
  'qb-recyclejob:client:target:toggleDuty',
  function()
    onDuty = not onDuty
    if onDuty then
      QBCore.Functions.Notify('You Have Been Clocked In', 'success')
    else
      QBCore.Functions.Notify('You Have Clocked Out', 'error')
      if pickupZone then
        pickupZone:destroy()
        pickupZone = nil
        packageCoords = nil
      end
    end
  end
)

RegisterNetEvent(
  'qb-recyclejob:client:target:pickupPackage',
  function()
    QBCore.Functions.Progressbar(
      'pickup_reycle_package',
      'Pick Up The Package ..',
      math.random(4000, 6000),
      false,
      true,
      {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
      },
      {},
      {},
      {},
      function()
        ClearPedTasks(PlayerPedId())
        PickupPackage()
        pickupZone:destroy()
        pickupZone = nil
        packageCoords = nil
      end
    )
  end
)

RegisterNetEvent(
  'qb-recyclejob:client:target:dropPackage',
  function()
    DropPackage()
    ScrapAnim()
    QBCore.Functions.Progressbar(
      'deliver_reycle_package',
      'Unpacking The Package',
      5000,
      false,
      true,
      {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
      },
      {},
      {},
      {},
      function()
        -- Done
        StopAnimTask(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
        TriggerServerEvent('qb-recycle:server:getItem')
      end
    )
  end
)

-- Threads

CreateThread(
  function()
    local sleep = 500

    while not LocalPlayer.state.isLoggedIn do
      -- do nothing
      Wait(sleep)
    end

    SetLocationBlip()
    RegisterEntranceTarget()

    while true do
      sleep = 500
      if not isInside then
        if isInsideEntranceZone then
          sleep = 0
          if IsControlJustReleased(0, 38) then
            TriggerEvent('qb-recyclejob:client:target:enterLocation')
            exports['qb-core']:HideText()
          end
        end
      else
        if isInsideExitZone then
          sleep = 0
          if IsControlJustReleased(0, 38) then
            TriggerEvent('qb-recyclejob:client:target:exitLocation')
            exports['qb-core']:HideText()
          end
        end

        if isInsideDutyZone then
          sleep = 0
          if IsControlJustReleased(0, 38) then
            TriggerEvent('qb-recyclejob:client:target:toggleDuty')
            exports['qb-core']:HideText()
          end
        end

        if onDuty then
          if not pickupZone and not carryPackage then
            GetRandomPackage()
          else
            if isInsidePickupZone and not carryPackage then
              sleep = 0
              if IsControlJustReleased(0, 38) then
                TriggerEvent('qb-recyclejob:client:target:pickupPackage')
                exports['qb-core']:HideText()
              end
            elseif packageCoords and not carryPackage then
              sleep = 0
              DrawMarker(2, packageCoords.x, packageCoords.y, packageCoords.z + 3, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, false, 2, true, nil, nil, false)
            end

            if isInsideDeliveryZone and carryPackage then
              sleep = 0
              if IsControlJustReleased(0, 38) then
                TriggerEvent('qb-recyclejob:client:target:dropPackage')
                exports['qb-core']:HideText()
              end
            end
          end
        end
      end

      Wait(sleep)
    end
  end
)
