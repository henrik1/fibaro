local GARAGE_ID = 29;
local SWITCH_ID = 11;

local TARGET_HOUR_MIN = 23; -- The earliest hour the auto close should initiate
local TARGET_HOUR_MAX = 7; -- The latest hour the auto close should initiate

local WAIT_BEFORE_CLOSE = 1; -- The amount of time the door should have been in state "Open" before it gets closed

local LAST_AUTO_CLOSE_TIMESTAMP = 0;
local LAST_OPENED_AT = 0;

local LAST_GARAGE_DOOR_STATE = fibaro:getValue(GARAGE_ID, "state");

function closeDoor ()
  fibaro:debug("Closing garage door");
  LAST_AUTO_CLOSE_TIMESTAMP = os.time();
end

function handleState (currentDoorState)

  fibaro:debug("LAST STATE: " .. LAST_GARAGE_DOOR_STATE .. ", CURRENT STATE: " .. currentDoorState);

  if (currentDoorState == "Closed") then
    fibaro:debug("Garage door is closed");
  end

  local currentHour = os.date("*t").hour;
  fibaro:debug("CURRENT HOUR: " .. currentHour);

  local currentTimestamp = os.time();
  fibaro:debug("CURRENT TIMESTAMP: " .. currentTimestamp);

  if (currentDoorState == "Open" and currentDoorState ~= LAST_GARAGE_DOOR_STATE) then
    -- Means the garage door was just opened
    LAST_OPENED_AT = currentTimestamp;
    fibaro:debug("Garage door has just opened, no need to close");
  elseif (currentDoorState == "Open") then
    -- Garage is open, check if we should close
    local durationOpen = os.difftime(currentTimestamp, LAST_OPENED_AT) / 60; -- duration since it was opened in minutes
    fibaro:debug("Garage door has been open for: " .. durationOpen .. " minutes");

    local minutesSinceLastAutoClose = os.difftime(currentTimestamp, LAST_AUTO_CLOSE_TIMESTAMP) / 60;
    fibaro:debug("Garage door was auto closed " .. minutesSinceLastAutoClose .. " minutes ago.");

    local isWithinAutoHours = currentHour > TARGET_HOUR_MIN or currentHour < TARGET_HOUR_MAX;
    fibaro:debug("The garage door is within auto hours? " .. (isWithinAutoHours and "true" or "false"));

    local isOpenForTooLong = durationOpen > WAIT_BEFORE_CLOSE;
    fibaro:debug("The garage door has stayed open for too long " .. (isOpenForTooLong and "true" or "false"));

    -- Not needed, will be taken care of already by tge isOpenForTooLong
    -- local isRecentlyAutoClosed == minutesSinceLastAutoClose > WAIT_BEFORE_CLOSE;
    -- fibaro:debug("The garage door has stayed open for too long");

    if (isWithinAutoHours and isOpenForTooLong) then
      closeDoor();
    end
  end

  LAST_GARAGE_DOOR_STATE = currentDoorState;
end


function run ()
  local doorState = fibaro:get(GARAGE_ID, "state");

  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD NOT CLOSE ");
  handleState("Open");

  fibaro:sleep(1000 * 60); -- wait for 1 minutes
  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD NOT CLOSE ");
  handleState("Open");

  fibaro:sleep(1000 * 60); -- wait for 1 additional minutes
  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD CLOSE ");
  handleState("Open");

  fibaro:sleep(1000 * 60); -- wait for 1 additional minutes
  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD NOT DO ANYTHING ");
  handleState("Closed");

  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD NOT CLOSE ");
  handleState("Open");

  fibaro:sleep(1000 * 180); -- wait for 3 minutes
  fibaro:debug(" ------------- ");
  fibaro:debug(" SHOULD CLOSE ");
  handleState("Open");


  -- fibaro:sleep(30000);
  -- run();
end

run();
