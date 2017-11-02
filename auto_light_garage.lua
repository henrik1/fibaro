--[[
%% properties
29 state
%% events
%% globals
--]]

-- Turns on / off the light in the garage depending if the door has opened
-- or closed. It does not turn light on/off if the garage door state hasn't
-- changed. This is useful, because in some cases one might want to have the
-- garage door closed, but still have the lights switched on.
-- It will also use a light sensor to determine if it's necessary to switch
-- lights on, eg. the lux value is below a given threshold

local GARAGE_ID = 29; -- Device ID for the garage door
local SWITCH_ID = 11; -- Device ID for the switch that controls lighting
local LIGHT_SENSOR_ID = 45;
local LUX_THRESHOLD = 1000;

function turnOff ()
  fibaro:debug('Turning off lights in garage');
  fibaro:call(SWITCH_ID, 'turnOff');
end

function turnOn ()
  fibaro:debug('Turning on lights in garage');
  fibaro:call(SWITCH_ID, 'turnOn');
end

function handleState (doorState, lightSensorState, lightSwitchState)
  fibaro:debug('Garage door state: ' .. doorState);
  fibaro:debug('Light switch state: ' .. lightSwitchState);
  fibaro:debug('Light sensor value ' .. lightSensorState);

  if (doorState == 'Open' and lightSensorState < LUX_THRESHOLD and lightSwitchState == 'false') then
    -- The garage door is open
    -- the light sensor value is below threshold,
    -- the light is off.
    -- Turn on light switch
    turnOn();
  elseif (doorState == 'Closed' and lightSwitchState == 'true') then
    -- The garage door is closed,
    -- the light is on.
    -- Turn off light
    turnOff();
  else
    fibaro:debug('No action needed');
  end
end


function run ()
  local doorState = fibaro:getValue(GARAGE_ID, 'state');
  local lightSwitchState = fibaro:getValue(GARAGE_ID, 'value');
  local lightSensorState = tonumber(fibaro:getValue(LIGHT_SENSOR_ID, 'value'));
end

-- allow only one instance of this scene to run at a time
if (fibaro:countScenes() > 1) then
    fibaro:abort()
end

run();
