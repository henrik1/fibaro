--[[
%% properties
%% events
%% globals
--]]


local GARAGE_ID = 29;

local TARGET_HOUR_MIN = 22; -- The earliest hour the auto close should initiate
local TARGET_HOUR_MAX = 7; -- The latest hour the auto close should initiate
local WAIT_BEFORE_CLOSE = 30; -- The amount of time the door should have been in state 'Open' before it gets closed

function closeDoor ()
  fibaro:debug('Closing garage door');
  fibaro:call(GARAGE_ID, 'close');
end


function handleState (currentDoorState)
  if (currentDoorState == 'Closed') then
    fibaro:debug('Garage door is closed');
  end

  local currentHour = os.date('*t').hour;
  local currentTimestamp = os.time();
  local lastModified = (currentTimestamp - fibaro:getModificationTime(GARAGE_ID, 'state')) / 60;

  fibaro:debug('Garage door state was changed: ' .. lastModified .. ' mins ago');

  if (currentDoorState == 'Open' and lastModified >= WAIT_BEFORE_CLOSE) then
    fibaro:debug('Garage door has been open for: ' .. lastModified .. ' minutes');

    local isWithinAutoHours = currentHour >= TARGET_HOUR_MIN or currentHour < TARGET_HOUR_MAX;
    fibaro:debug('The garage door is within auto closing hours: ' .. (isWithinAutoHours and 'true' or 'false'));

    local isOpenForTooLong = lastModified > WAIT_BEFORE_CLOSE;
    fibaro:debug('The garage door has stayed open too long ' .. (isOpenForTooLong and 'true' or 'false'));

    if (isWithinAutoHours and isOpenForTooLong) then
      closeDoor();
    end
  end
end


function run ()
  local doorState = fibaro:get(GARAGE_ID, 'state');

  handleState(doorState);

  fibaro:sleep(1000 * 60);
  run();
end

run();
