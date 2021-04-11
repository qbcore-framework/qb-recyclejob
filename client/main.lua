QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

local carryPackage = nil
---- MARKERS BINNEN/BUITEN/INKLOKKEN/AUTO
local onDuty = false
Citizen.CreateThread(function ()
    local RecycleBlip = AddBlipForCoord(Config['delivery'].outsideLocation.x, Config['delivery'].outsideLocation.y, Config['delivery'].outsideLocation.z)
    SetBlipSprite(RecycleBlip, 365)
    SetBlipColour(RecycleBlip, 2)
    SetBlipScale(RecycleBlip, 0.8)
    SetBlipAsShortRange(RecycleBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Recycle Center")
    EndTextCommandSetBlipName(RecycleBlip)
    while true do
        Citizen.Wait(7)
        local pos = GetEntityCoords(PlayerPedId(), true)
        ---- BUITEN
        if #(pos - vector3(Config['delivery'].outsideLocation.x, Config['delivery'].outsideLocation.y, Config['delivery'].outsideLocation.z)) < 1.3 then
            DrawText3D(Config['delivery'].outsideLocation.x, Config['delivery'].outsideLocation.y, Config['delivery'].outsideLocation.z + 1, "~g~E~w~ - To Enter")
            if IsControlJustReleased(0, 38) then
                DoScreenFadeOut(500)
                while not IsScreenFadedOut() do
                    Citizen.Wait(10)
                end
                SetEntityCoords(PlayerPedId(), Config['delivery'].insideLocation.x, Config['delivery'].insideLocation.y, Config['delivery'].insideLocation.z)
                DoScreenFadeIn(500)
            end
        end
        ---- BINNEN

            if #(pos - vector3(Config['delivery'].insideLocation.x, Config['delivery'].insideLocation.y, Config['delivery'].insideLocation.z)) < 1.3 then
                DrawText3D(Config['delivery'].insideLocation.x, Config['delivery'].insideLocation.y, Config['delivery'].insideLocation.z + 1, "~g~E~w~ - To Go Outside")
                if IsControlJustReleased(0, 38) then
                    DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do
                        Citizen.Wait(10)
                    end
                    SetEntityCoords(PlayerPedId(), Config['delivery'].outsideLocation.x, Config['delivery'].outsideLocation.y, Config['delivery'].outsideLocation.z + 1)
                    DoScreenFadeIn(500)
                end
            end
     
        ---- INKLOKKEN
        if #(pos - vector3(-1032.27,456.71,6.74)) < 15 and not IsPedInAnyVehicle(PlayerPedId(), false) and carryPackage == nil then
            DrawMarker(25, 1049.15,-3100.63,-39.95, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5001, 255, 0, 0,100, 0, 0, 0,0)
            if #(pos - vector3(-1032.27,456.71,6.74)) < 1.3 then
                if onDuty then
                    DrawText3D(-1032.27,456.71,6.74 + 1, "~g~E~w~ - Clock Out")
                else
                    DrawText3D(-1032.27,456.71,6.74 + 1, "~g~E~w~ -  Clock In")
                end
                if IsControlJustReleased(0, 38) then
                    onDuty = not onDuty
                    if onDuty then
                        QBCore.Functions.Notify("You Have Been Clocked In")
                    else
                        QBCore.Functions.Notify("You Have Clocked Out", "error")
                    end
                end
            end
        end
    
        if #(pos - vector3(-1025.16,432.95,6.24)) > 30 and onDuty then
            onDuty = false
            QBCore.Functions.Notify("You Have Clocked Out", "error")
        end
    end
end)

local packagePos = nil
Citizen.CreateThread(function ()
    for k, pickuploc in pairs(Config['delivery'].pickupLocations) do
        local model = GetHashKey(Config['delivery'].warehouseObjects[math.random(1, #Config['delivery'].warehouseObjects)])
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end
    while true do
        Citizen.Wait(7)
        if onDuty then
            if packagePos ~= nil then
                local pos = GetEntityCoords(PlayerPedId(), true)
                if carryPackage == nil then
                    if #(pos - vector3(packagePos.x, packagePos.y, packagePos.z)) < 2.3 then
                        DrawText3D(packagePos.x,packagePos.y,packagePos.z+ 1, "~g~E~w~ - Pack Package")
                        if IsControlJustReleased(0, 38) then
                            QBCore.Functions.Progressbar("pickup_reycle_package", "Pick Up The Package ..", math.random(4000, 6000), false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function()
                                ClearPedTasks(PlayerPedId())
                                PickupPackage()
                            end)
                        end
                    else
                        DrawText3D(packagePos.x, packagePos.y, packagePos.z + 1, "Package")
                    end
                else
                    if #(pos - vector3(Config['delivery'].dropLocation.x, Config['delivery'].dropLocation.y, Config['delivery'].dropLocation.z)) < 2.0 then
                        DrawText3D(Config['delivery'].dropLocation.x, Config['delivery'].dropLocation.y, Config['delivery'].dropLocation.z, "~g~E~w~ - Hand In The Package")
                        if IsControlJustReleased(0, 38) then
                            DropPackage()
                            ScrapAnim()
                            QBCore.Functions.Progressbar("deliver_reycle_package", "Unpacking The Package", 5000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function() -- Done
                                StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
                                TriggerServerEvent('qb-recycle:server:getItem')
                                GetRandomPackage()
                            end)
                        end
                    else
                        DrawText3D(Config['delivery'].dropLocation.x, Config['delivery'].dropLocation.y, Config['delivery'].dropLocation.z, "Hand In")
                    end
                end
            else
                GetRandomPackage()
            end
        end
    end
end)

function ScrapAnim()
    local time = 5
    loadAnimDict("mp_car_bomb")
    TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
            end
        end
    end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function GetRandomPackage()
    local randSeed = math.random(1, #Config["delivery"].pickupLocations)
    packagePos = {}
    packagePos.x = Config["delivery"].pickupLocations[randSeed].x
    packagePos.y = Config["delivery"].pickupLocations[randSeed].y
    packagePos.z = Config["delivery"].pickupLocations[randSeed].z
end

function PickupPackage()
    local pos = GetEntityCoords(PlayerPedId(), true)
    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey("prop_cs_cardbox_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local object = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end

function DropPackage()
    ClearPedTasks(PlayerPedId())
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
end