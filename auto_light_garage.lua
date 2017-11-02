--[[
%% properties
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
local MAX_MODIFCATION_TIME = 5;

function turnOff ()
  fibaro:debug('Turning off lights in garage');
  fibaro:call(SWITCH_ID, 'turnOff');

  -- Adding extra sleep to prevent off when switched on after garage was closed
  fibaro:sleep(1000);
end

function turnOn ()
  fibaro:debug('Turning on lights in garage');
  fibaro:call(SWITCH_ID, 'turnOn');

  -- Adding extra sleep to prevent off when switched on after garage was closed
  fibaro:sleep(1000);
end

function handleState (doorState, lightSensorState, lightSwitchState)
  fibaro:debug('Garage door state: ' .. doorState);
  fibaro:debug('Light switch state: ' .. lightSwitchState);
  fibaro:debug('Light sensor value ' .. lightSensorState);

  local lastModified = os.time() - fibaro:getModificationTime();
  fibaro:debug('The garage door state was modified: ' .. lastModified .. ' seconds ago');

  local isRecentlyModified = lastModified < MAX_MODIFCATION_TIME;

  if (doorState == 'Open' and isRecentlyModified and lightSensorState < LUX_THRESHOLD and lightSwitchState == 'false') then
    -- The garage door is open and it was recently opened,
    -- the light sensor value is below threshold,
    -- the light is off. We should turn on light
    turnOn();
  elseif (doorState == 'Closed' and isRecentlyModified and lightSwitchState == 'true') then
    -- The garage door is closed and it was recently closed,
    -- the light is on. We should turn off light
    turnOff();
  else
    fibaro:debug('No action needed');
  end
end


function run ()
  local doorState = fibaro:getValue(GARAGE_ID, 'value');
  local lightSwitchState = fibaro:getValue(GARAGE_ID, 'value');
  local lightSensorState = tonumber(fibaro:getValue(LIGHT_SENSOR_ID, 'value'));

  fibaro:sleep(MAX_MODIFCATION_TIME * 1000);
  run();
end

run();
