local module    = {}
local radar     = import '@Index/radar';
local vehicle   = import 'vehicle';
local nui       = import 'nui';
local vehicles  = array.data('vehicles');
local usingShop = nil
local color     = 1

RegisterNUICallback("ChangeVehicle", function(vehId, cb)
  local Index = vehicles:find(function(veh)
    return veh.id == vehId
  end)

  if not Index then
    return warn("Not found vehicle : " .. vehId);
  end

  if not usingShop then
    return warn("Not found shop using");
  end

  if not IsModelInCdimage(Index.model) then
    cb(true)
    return warn("Not found model : " .. Index.model)
  end

  usingShop.change(Index)
  cb(true)
end)

RegisterNuiCallback("ChangeColored", function(val, cb)
  cb(1)
  if not usingShop then
    return warn("Not found shop using");
  end

  color = tonumber(val)
  usingShop.color(color)
end)

function module.new(payload)
  local point = lib.points.new({ coords = payload.coords, distance = 100 })
  local self = {}
  self.veh = nil;

  function point:onEnter()
    local Index = vehicles:find(function(veh)
      return veh.category == payload.categories[1] and IsModelInCdimage(veh.model)
    end)

    if not Index then
      return error("no found vehicle");
    end

    local onChange = function(Index)
      if (not self.veh) then
        return warn("NOT FOUND STARTER VEHICLE");
      end

      self.veh = self.veh:replace(Index.model)
      nui.stats(self.veh.stats())
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

      usingShop = {
        change = onChange,
        properties = self.veh.getProperties,
        color = function()
          self.veh:set("color", color, color)
        end
      }
    end)

    self.veh.on("onLeave", function()
      usingShop = nil;
      nui.close()
    end)
  end

  function point:onExit()
    nui.reset();

    if not self.veh then
      return
    end

    self.veh:destroy();
  end

  function self:destroy()
    if not self.veh then
      return
    end

    self.veh:destroy();
  end

  return self
end

function module.getPreviewProperties()
  if not usingShop then
    return {}
  end

  return usingShop.properties()
end

return module
