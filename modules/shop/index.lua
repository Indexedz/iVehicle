local module   = {}
local radar    = import '@Index/radar';
local vehicle  = import 'vehicle';
local nui      = import 'nui';
local vehicles = array.data('vehicles');
local shop     = nil
local color    = 1

function module.new(payload)
  local point = lib.points.new({ coords = payload.coords, distance = 100 })
  local self = {}
  self.veh = nil;

  local function onEnter()
    local Index = vehicles:find(function(veh)
      return veh.category == payload.categories[1] and IsModelInCdimage(veh.model)
    end)

    if not Index then
      return error("no found vehicle");
    end

    self.veh = vehicle.new(Index.model, payload.coords, false, {
      freeze     = true,
      plate      = "BUY ME",
      invincible = true,
      color      = { color, color },
    })

    self.veh.on("onEnter", function()
      nui.open(payload.id, Index.id)
      radar.set(false);

      CreateThread(function()
        Wait(1000)
        nui.stats(self.veh.stats())
      end)

      shop = self;
    end)

    self.veh.on("onLeave", function()
      nui.close()

      shop = nil
    end)
  end

  local function onExit()
    nui.reset();

    if not self.veh then
      return
    end

    self.veh:destroy();
  end

  function self.change(Index)
    if (not self.veh) then
      return warn("NOT FOUND STARTER VEHICLE");
    end

    self.veh = self.veh:replace(Index.model)
    nui.stats(self.veh.stats())
  end

  function self.color()
    if not self.veh then
      return warn 'not found vehicle'
    end

    return self.veh:set("color", color, color)
  end

  function self.properties()
    if not self.veh then
      return warn 'not found vehicle'
    end

    return self.veh.getProperties();
  end

  function self:destroy()
    if not self.veh then
      return
    end

    self.veh:destroy();
  end

  function point:onEnter()
    return onEnter()
  end

  function point:onExit()
    return onExit
  end

  return self
end

function module.getPreviewProperties()
  if not shop then
    return {}
  end

  return shop.properties()
end

function module.changeVehicle(vehId, cb)
  cb(true)
  local Index = vehicles:find(function(veh)
    return veh.id == vehId
  end)

  if not Index then
    return warn("Not found vehicle : " .. vehId);
  end

  if not IsModelInCdimage(Index.model) then
    cb(true)
    return warn("Not found model : " .. Index.model)
  end

  shop.change(Index)
end

function module.changeColored(val, cb)
  cb(true)
  color = tonumber(val)
  shop.color(color)
end

return module
