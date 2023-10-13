local player             = import '@Index/player';
local behavior           = player.behavior();
local player             = player.localPlayer();
local seatbelt           = player.useState(false, 'seatbelt')
local isInVehicleShop    = player.useState(false, 'isInVehicleShop')
local handbrake          = 0
local sleep              = 0
local newVehBodyHealth   = 0
local currVehBodyHealth  = 0
local frameBodyChange    = 0
local lastFrameVehSpeed  = 0
local lastFrameVehSpeed2 = 0
local thisFrameVehSpeed  = 0
local tick               = 0
local damageDone         = false
local modifierDensity    = true
local lastVeh            = nil
local veloc

-- Functions

local function ejectFromVehicle()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
  SetEntityCoords(ped, coords.x, coords.y, coords.z)
  Wait(1)
  SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
  SetEntityVelocity(ped, veloc.x * 4, veloc.y * 4, veloc.z * 4)
  local ejectSpeed = math.ceil(GetEntitySpeed(ped) * 8)
  if GetEntityHealth(ped) - ejectSpeed > 0 then
    SetEntityHealth(ped, GetEntityHealth(ped) - ejectSpeed)
  elseif GetEntityHealth(ped) ~= 0 then
    SetEntityHealth(ped, 0)
  end
end

local function toggleSeatbelt()
  seatbelt:set(not seatbelt.get())
  SeatBeltLoop()
end

local function resetHandBrake()
  if handbrake <= 0 then return end
  handbrake -= 1
end

function SeatBeltLoop()
  CreateThread(function()
    while seatbelt.get() do
      if seatbelt.get() then
        DisableControlAction(0, 75, true)
        DisableControlAction(27, 75, true)
      end
      if not IsPedInAnyVehicle(PlayerPedId(), false) then
        seatbelt:set(false)
        break
      end

      Wait(0)
    end
  end)
end

behavior.on("InVehicle", function(...)
  local ped = PlayerPedId()
  if isInVehicleShop.get() then
    return warn("is in vehicle shop do not use belt")
  end

  while IsPedInAnyVehicle(ped, false) do
    Wait(0)
    local currVehicle = GetVehiclePedIsIn(ped, false)
    if currVehicle and currVehicle ~= false and currVehicle ~= 0 then
      SetPedHelmet(ped, false)
      lastVeh = GetVehiclePedIsIn(ped, false)
      if GetVehicleEngineHealth(currVehicle) < 0.0 then
        SetVehicleEngineHealth(currVehicle, 0.0)
      end
      if (GetVehicleHandbrake(currVehicle) or (GetVehicleSteeringAngle(currVehicle)) > 25.0 or (GetVehicleSteeringAngle(currVehicle)) < -25.0) then
        if handbrake == 0 then
          handbrake = 100
          resetHandBrake()
        else
          handbrake = 100
        end
      end

      thisFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
      currVehBodyHealth = GetVehicleBodyHealth(currVehicle)
      if currVehBodyHealth == 1000 and frameBodyChange ~= 0 then
        frameBodyChange = 0
      end
      if frameBodyChange ~= 0 then
        if lastFrameVehSpeed > 110 and thisFrameVehSpeed < (lastFrameVehSpeed * 0.75) and not damageDone then
          if frameBodyChange > 18.0 then
            if not seatbelt.get() and not IsThisModelABike(currVehicle) then
              if math.random(math.ceil(lastFrameVehSpeed)) > 60 then
                ejectFromVehicle()
              end
            elseif (seatbelt.get()) and not IsThisModelABike(currVehicle) then
              if lastFrameVehSpeed > 150 then
                if math.random(math.ceil(lastFrameVehSpeed)) > 150 then
                  ejectFromVehicle()
                end
              end
            end
          else
            if not seatbelt.get() and not IsThisModelABike(currVehicle) then
              if math.random(math.ceil(lastFrameVehSpeed)) > 60 then
                ejectFromVehicle()
              end
            elseif (seatbelt.get()) and not IsThisModelABike(currVehicle) then
              if lastFrameVehSpeed > 120 then
                if math.random(math.ceil(lastFrameVehSpeed)) > 200 then
                  ejectFromVehicle()
                end
              end
            end
          end
          damageDone = true
          SetVehicleEngineOn(currVehicle, false, true, true)
        end
        if currVehBodyHealth < 350.0 and not damageDone then
          damageDone = true
          SetVehicleEngineOn(currVehicle, false, true, true)
          Wait(1000)
        end
      end
      if lastFrameVehSpeed < 100 then
        Wait(100)
        tick = 0
      end
      frameBodyChange = newVehBodyHealth - currVehBodyHealth
      if tick > 0 then
        tick -= 1
        if tick == 1 then
          lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
        end
      else
        if damageDone then
          damageDone = false
          frameBodyChange = 0
          lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
        end
        lastFrameVehSpeed2 = GetEntitySpeed(currVehicle) * 3.6
        if lastFrameVehSpeed2 > lastFrameVehSpeed then
          lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
        end
        if lastFrameVehSpeed2 < lastFrameVehSpeed then
          tick = 25
        end
      end
      if tick < 0 then
        tick = 0
      end
      newVehBodyHealth = GetVehicleBodyHealth(currVehicle)
      if not modifierDensity then
        modifierDensity = true
      end
      veloc = GetEntityVelocity(currVehicle)
    else
      if lastVeh then
        SetPedHelmet(ped, true)
        Wait(200)
        newVehBodyHealth = GetVehicleBodyHealth(lastVeh)
        if not damageDone and newVehBodyHealth < currVehBodyHealth then
          damageDone = true
          SetVehicleEngineOn(lastVeh, false, true, true)
          Wait(1000)
        end
        lastVeh = nil
      end
      lastFrameVehSpeed2 = 0
      lastFrameVehSpeed = 0
      newVehBodyHealth = 0
      currVehBodyHealth = 0
      frameBodyChange = 0
      Wait(2000)
      break
    end
  end
end)

-- Register Key
RegisterCommand('ToggleSeatbelt', function()
  if not IsPedInAnyVehicle(PlayerPedId(), false) or IsPauseMenuActive() then return end
  local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))
  if class == 8 or class == 13 or class == 14 then return end
  toggleSeatbelt()
end, false)

RegisterKeyMapping('ToggleSeatbelt', 'Toggle Seatbelt', 'keyboard', 'B')
