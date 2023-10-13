local module       = {}
local player       = import '@Index/player';
local categories   = array.data('categories');
local vehicles     = array.data('vehicles');
local shops        = array.data('shops');
local isInShop     = player.useState(false, "isInVehicleShop")
local visiblity    = false;
local setupVehicle = false;
local currentShop  = 0
local oldShop      = 0

local function onVisible()
  local focus = false;
  CreateThread(function()
    while visiblity do
      Wait(1)

      if focus then
        DisableAllControlActions(0)
      end

      if IsDisabledControlJustPressed(0, 25) then
        if not focus then
          SetNuiFocus(true, true)
          SetCursorLocation(0.5, 0.5)
          SetNuiFocusKeepInput(true)
          module.send("setFocus", true)
          focus = true
        else
          SetNuiFocus(false, false)
          module.send("setFocus", false)
          focus = false
        end
      end
    end
  end)
end

function module.send(header, props)
  SendNUIMessage({
    header = header,
    props = props
  })
end

function module.sends(data)
  local payloads = array.new();

  array.new(data):map(function(payload)
    payloads:push({
      header = payload[1],
      props = payload[2]
    })
  end)

  SendNUIMessage({
    isMultiple = true,
    props = payloads
  })
end

function module.setVisiblity(boolean)
  if boolean == visiblity then
    return
  end

  visiblity = boolean
  return module.send('setVisiblity', boolean)
end

function module.open(ShopId, VehicleId)
  local shop = shops:find(function(shop)
    return shop.id == ShopId
  end)

  if not shop then
    return warn("shop not found")
  end

  if currentShop == ShopId then
    return
  end

  currentShop = ShopId
  visiblity = true;
  isInShop:set(true);

  local tasks = array.new({
    { "setVisiblity", true }
  })

  if oldShop ~= currentShop then
    local shopStock = array.new(shop.categories)
    local categories = categories:filter(function(category)
      return shopStock:find(function(id)
        return id == category.id
      end)
    end)

    tasks:push({ "SetupCategories", categories })
    tasks:push({ "setDefaultCategory", categories[1].id })
    tasks:push({ "setDefaultVehicle", VehicleId })

    if not setupVehicle then
      tasks:push({ "SetupVehicles", vehicles })
      setupVehicle = true
    end
  end

  module.sends(tasks)
  SetNuiFocus(true, false)
  NetworkStartSoloTutorialSession()
  onVisible()
end

function module.close()
  oldShop = currentShop
  currentShop = 0

  isInShop:set(false);
  module.setVisiblity(false)
  SetNuiFocus(false, false)
  NetworkEndTutorialSession()
end

function module.stats(stats)
  local payload = array.new({
    { id = "speed", label = "ความเร็วสูงสุด (kp/h)", value = stats.speed },
    { id = "acceleration", label = "อัตราเร่ง", value = stats.acceleration * 150, format = "grade" },
    { id = "handler", label = "การควบคุม", value = stats.handler * 10, format = "grade" },
    { id = "braking", label = "เบรค", value = stats.braking * 80, format = "grade" },
    { id = "gears", label = "เกียร์", value = stats.gears },
    { id = "seats", label = "ที่นั่ง", value = stats.seats }
  })

  if (stats.trunk[1] ~= nil) then
    payload:push({
      id = "trunk",
      label = not stats.isHood and "ที่เก็บของท้ายรถ" or "ที่เก็บของหน้ารถ",
      value = stats.trunk[1],
      weight = stats.trunk[2]
    })
  end

  if (stats.glovebox[1] ~= nil) then
    payload:push({
      id = "glovebox",
      label = "ที่เก็บของในรถ",
      value = stats.glovebox[1],
      weight = stats.glovebox[2]
    })
  end

  return module.send("initStats", payload)
end

function module.reset()
  currentShop = 0
  oldShop = 0
end

return module
