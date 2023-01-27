local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-recycle:server:getItem', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  for _ = 1, math.random(1, Config.MaxItemsReceived), 1 do
    local randItem = Config.ItemTable[math.random(1, #Config.ItemTable)]
    local amount = math.random(Config.MinItemReceivedQty, Config.MaxItemReceivedQty)
    Player.Functions.AddItem(randItem, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add')
    Wait(500)
  end

  local luck = math.random(1, 10)
  local odd = math.random(1, 10)
  if luck == odd then
    local random = math.random(1, 3)
    Player.Functions.AddItem(Config.LuckyItem, random)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LuckyItem], 'add')
  end
end)

RegisterNetEvent('qb-recycle:server:getItem', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local amount = math.random(1, 3)
  
  Player.Functions.AddItem("recycledmaterials", amount)
  TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'add', amount)
  Wait(500)
  
  local chance = math.random(1, 100)
  if chance < 7 then
      Player.Functions.AddItem("cryptostick", 1, false)
      TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add")
  end

end)


-------------------
-- INPUT AMOUNT --
-------------------

RegisterNetEvent("qb-recyclejob:TradeInput", function(item, amount)
  print(item, amount)
  local src = source
  local tradeamount = tonumber(amount)
  local Player = QBCore.Functions.GetPlayer(src)
  local pay = (Config.ItemPrices[item].price * tradeamount)

  if item == 'cash' then
      local pay = (tradeamount * Config.ItemPrices["cash"].price)
      Player.Functions.RemoveItem('recycledmaterials', tradeamount)
      TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'remove', tradeamount)
      Player.Functions.AddMoney('cash', pay)
  else
      if Player.Functions.GetItemByName("recycledmaterials") ~= nil then
          Player.Functions.RemoveItem('recycledmaterials', tradeamount)
          TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'remove', tradeamount)
          Player.Functions.AddItem(item, pay)
          TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', pay)
      end
  end
end)

-------------------
-- TRADE ONE --
-------------------

RegisterNetEvent("qb-recyclejob:TradeOne", function(item)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)

  if Player.Functions.GetItemByName("recycledmaterials") ~= nil then
      local pay = Config.ItemPrices[item].price

      Player.Functions.RemoveItem('recycledmaterials', 1)
      TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'remove', 1)
      Player.Functions.AddItem(item, pay)
      TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', pay)
  end
end)

-------------------
-- TRADE ALL --
-------------------

RegisterNetEvent("qb-recyclejob:TradeAll", function(item)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local amount = Player.Functions.GetItemByName("recycledmaterials").amount -- Gets amount of recycled materials
  local itemamount = Config.ItemPrices[item].price -- Gets price of each item
  local pay = (amount * itemamount)

  if item == 'cash' then
      Player.Functions.RemoveItem('recycledmaterials', amount)
      TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'remove', amount)
      Player.Functions.AddMoney('cash', pay)
  else
      if Player.Functions.GetItemByName("recycledmaterials") ~= nil then
          Player.Functions.RemoveItem('recycledmaterials', amount)
          TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['recycledmaterials'], 'remove', amount)
          Player.Functions.AddItem(item, pay)
          TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', pay)
      end
  end
end)