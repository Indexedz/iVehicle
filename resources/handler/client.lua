local callback = import '@Index/callback';
local event    = import '@Index/event';
local nui      = import 'nui';
local shop     = import 'shop';
local matrix   = import 'matrix';
local vehicle  = import 'vehicle';
local shops    = array.new();

CreateThread(function()
  local data = array.data('shops');

  data:map(function(payload)
    shops:push(shop.new(payload))
  end)
end)

RegisterNUICallback("ChangeVehicle", shop.changeVehicle)
RegisterNuiCallback("ChangeColored", shop.changeColored)
RegisterNUICallback('BuyVehicle', function(payload, cb)
  nui.close();

  payload.properties = shop.getPreviewProperties();
  local currentShop = shop.getCurrentShop();
  local model = payload.properties.model;
  local parking = currentShop.parking;
  local ped = PlayerPedId()

  if not currentShop then
    return warn 'not found shop';
  end

  if currentShop.veh then
    TaskLeaveVehicle(ped, currentShop.veh.handler, 0)
  end

  local state, code = callback.use("@vehicle-shop:buy", payload)

  if not state then
    return lib.notify({
      id = "buy-vehicle",
      title = "เกิดข้อผิดพลาด",
      type = "error",
      description = (
        ({
          "ไม่พบพาหนะดังกล่าวในร้านค้า",
          "เงินของคุณไม่เพียงพอสำหรับการซื้อรถดังกล่าว"
        })[code] or "กรุณาลองใหม่อีกครั้งภายหลัง"
      )
    })
  end

  lib.notify({
    id = "buy-vehicle",
    title = "แจ้งเตือน",
    type = "success",
    description = ("รายการสั่งซื้อของคุณสำเร็จแล้ว!")
  })
  local modelSize = matrix.getModelSize(model)
  local parking = parking.first(modelSize)

  if not parking then
    return lib.notify({
      id = "buy-vehicle-info",
      title = "แจ้งเตือน",
      type = "error",
      description = ("ไม่สามารถนำพาหนะออกมาได้ พาหนะของคุณจะถูกจัดเก็บไว้ในการาจ!")
    })
  end

  local properties = code;
  local veh = vehicle.new(model, parking, true, { plate = properties.plate });
  SetEntityDrawOutline(veh.handler, true)
  SetEntityDrawOutlineColor(veh.handler, 255, 255, 255, 20)
  SetEntityDrawOutlineShader(0)
  veh.setProperties(properties)
  CreateThread(function ()
    while true do
      Wait(500)

      local distance = #(GetEntityCoords(ped)-GetEntityCoords(veh.handler))
      if (distance <= 5) then
        SetEntityDrawOutline(veh.handler, false)
        break;
      end
    end
  end)
end)

event.onStop(function()
  shops:map(function(shop)
    shop:destroy();
  end)
end)
