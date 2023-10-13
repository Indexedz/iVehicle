local callback = import '@Index/callback';
local event    = import '@Index/event';
local nui      = import 'nui';
local shop     = import 'shop';
local shops    = array.new();

CreateThread(function()
  local data = array.data('shops');

  data:map(function(payload)
    shops:push(shop.new(payload))
  end)
end)

RegisterNUICallback('BuyVehicle', function(payload, cb)
  cb(true);
  nui.close();

  payload.properties = shop.getPreviewProperties();
  local success, code = callback.use("@vehicle-shop:buy", payload)
end)

event.onStop(function()
  shops:map(function(shop)
    shop:destroy();
  end)
end)
