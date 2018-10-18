--[[
%% properties
0 value
%% events
%% globals
--]]

local deviceId = 0;
local apiKey = 'APIKEY';
local api = '/api/devices/ID/status';
local host = 'https://ffthings.herokuapp.com';


function successCallback (resp)
  fibaro:debug('success');
  fibaro:debug(resp.data);
end

function httpError ()
  fibaro:debug('Failure');
end

function postTemperature ()
  local currentValue = tonumber(fibaro:getValue(deviceId, 'value'));
  local json = json.encode({ value = currentValue });

  local http = net.HTTPClient()
  http:request(host .. api,
  {
    options = {
      method = 'POST',
      headers = {
        ['x-api-token'] = apiKey,
        ['Content-Type'] = 'application/json'
      },
      data = json
    },
    success = successCallback,
    error = httpError
  })
end

postTemperature();
