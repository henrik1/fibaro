--[[
%% properties
%% events
%% globals
--]]


local DOOR_LOCK_ID = 56; -- Device id of the door lock
local TARGET_HOUR_MIN = 22; -- The earliest hour the auto close should initiate
local TARGET_HOUR_MAX = 7; -- The latest hour the auto close should initiate
local WAIT_BEFORE_CLOSE = 20; -- The amount of time the door should have been in state 'Open' before it gets closed
local LAST_DOOR_STATE = fibaro:get(DOOR_LOCK_ID, 'value');


function lockDoor ()
  fibaro:debug('Locking door');
  fibaro:call(DOOR_LOCK_ID, 'secure');
end


function handleState (currentDoorState)
  if (currentDoorState == '1') then
    fibaro:debug('Door is locked');
  end

  local currentHour = os.date('*t').hour;
  local currentTimestamp = os.time();
  local lastModified = (currentTimestamp - fibaro:getModificationTime(DOOR_LOCK_ID, 'value')) / 60;

  fibaro:debug('Door state was changed: ' .. lastModified .. ' minutes ago');

  if (currentDoorState == '0') then
    fibaro:debug('Door has been open for: ' .. lastModified .. ' minutes');

    local isWithinAutoHours = currentHour >= TARGET_HOUR_MIN or currentHour < TARGET_HOUR_MAX;
    fibaro:debug('Door is within auto lock hours: ' .. (isWithinAutoHours and 'true' or 'false'));

    local isOpenForTooLong = lastModified > WAIT_BEFORE_CLOSE;
    fibaro:debug('Door has stayed open for too long: ' .. (isOpenForTooLong and 'true' or 'false'));

    if (isWithinAutoHours and isOpenForTooLong) then
      lockDoor();
    end
  end

end



function run ()
  local doorState = fibaro:getValue(DOOR_LOCK_ID, 'value');

  handleState(doorState);

  fibaro:sleep(1000 * 60);
  run();
end

run();
