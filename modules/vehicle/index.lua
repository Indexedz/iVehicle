local module = {}
local player = import '@Index/player'.localPlayer();
local inventory = data '@ox_inventory/vehicles';
local matrix = import 'matrix';
local deformation = exports['deformation']
local states = array.new({
  { 'plate',      SetVehicleNumberPlateText, "IBLOCK" },
  { 'invincible', SetEntityInvincible,       false },
  { 'freeze',     FreezeEntityPosition,      false },
  { 'lock',       SetVehicleDoorsLocked,     0 },
  { 'color',      SetVehicleColours,         { 1, 1 } }
})

local _CreateVehicle = CreateVehicle
local function CreateVehicle(model, vec, networked)
  local handler = _CreateVehicle(model, vec.x, vec.y, vec.z, vec.w, networked, false)

  if networked then
    local id = NetworkGetNetworkIdFromEntity(handler)
    SetNetworkIdCanMigrate(id, true)
    SetEntityAsMissionEntity(handler, true, true)
  end

  SetVehicleHasBeenOwnedByPlayer(handler, true)
  SetVehicleNeedsToBeHotwired(handler, false)
  SetModelAsNoLongerNeeded(model)
  SetVehRadioStation(handler, 'OFF')
  SetVehicleDirtLevel(handler, 0.0)
  RequestCollisionAtCoord(vec.xyz)
  while not HasCollisionLoadedAroundEntity(handler) do
    Wait(0)
  end

  Entity(handler).state.fuel = 100
  return handler
end

local function GetVehicleInventory(model, vehicleClass)
  local vehicleHash = GetHashKey(model);
  local checkVehicle = inventory.Storage[vehicleHash]

  local invs = {
    glovebox = {},
    trunk = {},
    isHood = false
  }

  if (checkVehicle == 0 or checkVehicle == 1) or (not inventory.trunk[vehicleClass] and not inventory.trunk.models[vehicleHash]) then
    return invs
  end

  invs.glovebox = inventory.glovebox.models[vehicleHash] or inventory.glovebox[vehicleClass]
  invs.trunk = inventory.trunk.models[vehicleHash] or inventory.trunk[vehicleClass]

  if (checkVehicle == 2) then
    invs.glovebox = {}
  end

  if (checkVehicle == 3) then
    invs.isHood = true
  end

  return invs
end

local state = player.getState('@vehicle:entity');
local seatState = player.getState('@vehicle:seat');
local events = array.new({});

state.onChange(function(veh, oldVeh)
  events:map(function(event)
    if event.handler == veh and event.name == "onEnter" then
      pcall(event.cb)
    elseif event.handler == oldVeh and event.name == "onLeave" then
      pcall(event.cb)
    end
  end)
end)

function module.new(model, vec, networked, defaultStates, _resource)
  lib.requestModel(model)

  local self = {}
  self.handler = CreateVehicle(model, vec, networked)
  self.networked = networked
  self.model = model
  self.states = {}

  local defaultStates = defaultStates or {}
  states:map(function(state)
    local name, fn, defaultValue = state[1], state[2], defaultStates[state[1]] or state[3]
    fn(self.handler, type(defaultValue) == "table" and table.unpack(defaultValue) or defaultValue);
    self.states[name] = defaultValue
  end)

  function self.get(value)
    if value then
      return self.states[value]
    end

    return self.states
  end

  function self:destroy()
    SetEntityAsMissionEntity(self.handler, true, true)
    DeleteVehicle(self.handler)
  end

  local function setState(name, ...)
    local args = table.pack(...);
    local state = states:find(function(state)
      return state[1] == name
    end)

    state[2](self.handler, table.unpack(args))
    self.states[name] = #args <= 1 and table.unpack(args) or args

    return self
  end

  function self:set(...)
    return setState(...)
  end

  function self.getProperties()
    local properties = lib.getVehicleProperties(self.handler)
    properties.deformation = deformation:GetVehicleDeformation(self.handler)

    return properties
  end

  function self.setProperties(properties)
    if (properties.deformation) then
      deformation:SetVehicleDeformation(self.handler, properties.deformation)
    end

    properties.deformation = nil
    return lib.setVehicleProperties(self.handler, properties)
  end

  function self:onGround()
    return SetVehicleOnGroundProperly(self.handler)
  end

  function self.on(event, cb)
    return events:push({
      handler = self.handler,
      name = event,
      cb = cb,
      resource = _resource
    })
  end

  function self.coords()
    return vec4(
      GetEntityCoords(self.handler),
      GetEntityHeading(self.handler)
    )
  end

  function self.stats()
    local fTractionBiasFront = GetVehicleHandlingFloat(self.handler, 'CHandlingData', 'fTractionBiasFront')
    local fTractionCurveMax = GetVehicleHandlingFloat(self.handler, 'CHandlingData', 'fTractionCurveMax')
    local fTractionCurveMin = GetVehicleHandlingFloat(self.handler, 'CHandlingData', 'fTractionCurveMin')
    local inventory = GetVehicleInventory(self.model, GetVehicleClass(self.handler))
    local data = {}
    data.acceleration = GetVehicleModelAcceleration(self.model)
    data.speed = GetVehicleEstimatedMaxSpeed(self.handler) * 3.6
    data.handler = (fTractionBiasFront + fTractionCurveMax * fTractionCurveMin)
    data.braking = GetVehicleHandlingFloat(self.handler, 'CHandlingData', 'fBrakeForce')
    data.seats = GetVehicleMaxNumberOfPassengers(self.handler) + 1
    data.gears = GetVehicleHighGear(self.handler)
    data.glovebox = inventory.glovebox
    data.trunk = inventory.trunk
    data.isHood = inventory.isHood

    return data
  end

  function self.getSize()
    return matrix.getModelSize(self.model)
  end

  function self:replace(model, coords)
    local PlayerVehicle  = state.get();
    local CurrentVehicle = self;
    local CurrentSeat    = seatState.get();
    local NewVehicle     = module.new(model, coords or self.coords(), self.networked, CurrentVehicle.get())

    -- Replace Events
    events               = events:map(function(event)
      if (event.handler == CurrentVehicle.handler) then
        event.handler = NewVehicle.handler
        return event
      end
    end)

    -- Teleport Player
    CreateThread(function()
      if (PlayerVehicle == CurrentVehicle.handler) then
        TaskWarpPedIntoVehicle(PlayerPedId(), NewVehicle.handler, CurrentSeat)
      end
    end)

    -- OVERRIDE
    CurrentVehicle:destroy();
    self = NewVehicle;
    return self
  end

  return self
end

return module
