local callback = import '@Index/callback';
local player = import '@Index/player';
local utils = import '@Index/utils';
local db = import '@Index/db';

local vehicles = array.data 'vehicles';

callback.new("@vehicle-shop:buy", function(src, payload)
  local _, xCharacter = player.find(src);
  local veh           = vehicles:find(function(veh) return veh.id == payload.id end)
  local money         = xCharacter.Account(payload.statement == "0" and "cash" or "bank");

  if not veh then
    return false, 1
  end

  if (money.get() < veh.price) then
    return false, 2
  end

  local function insertVehicle()
    local plate = utils.randChar(10):upper()
    local properties = payload.properties;
    properties.deformation = properties.deformation or {};
    properties.plate = plate;
    properties.fuelLevel = 100;

    local insert, err = db.insert('vehicles', {
      charId = xCharacter.charId,
      plate = plate,
      vehicle = veh.id,
      properties = json.encode(properties)
    })

    if (not insert and err:find("Duplicate")) then
      Wait(500)
      return insertVehicle()
    end

    if (not insert) then
      return error("CANNOT INSERT VEHICLE TO DATABASE : " .. err)
    end

    return properties, err
  end

  money:remove(veh.price, "BUY VEHICLE")
  return true, insertVehicle()
end)