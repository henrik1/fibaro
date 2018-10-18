--[[
%% properties
%% events
%% globals
--]]

local latitude, longitude = 60.34375120000001, 5.2862659 -- Bergen, Norway
local PI = math.pi
local sin = math.sin
local cos = math.cos
local tan = math.tan
local asin = math.asin
local atan = math.atan2
local acos = math.acos
local deg = math.deg
local rad = PI / 180
local e = rad * 23.4397 -- obliquity of the Earth
local daysec = 60 * 60 * 24
local J1970 = 2440588
local J2000 = 2451545

function toDays(time)
  return time / daysec - 0.5 + J1970 - J2000
end

function rightAscension(l, b)
  return atan(sin(l) * cos(e) - tan(b) * sin(e), cos(l))
end

function declination(l, b)
  return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l))
end

function azimuth(H, phi, dec)
  return atan(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi))
end

function altitude(H, phi, dec)
  return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H))
end

function siderealTime(d, lw)
  return rad * (280.16 + 360.9856235 * d) - lw
end

function astroRefraction(h)
  if h < 0 then -- the following formula works for positive altitudes only.
    h = 0 -- if h = -0.08901179 a div/0 would occur.
  end

  -- formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  -- 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
  return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179))
end

-- general sun calculations
function solarMeanAnomaly(d)
  return rad * (357.5291 + 0.98560028 * d)
end

function eclipticLongitude(M)
  local C = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M)) -- equation of center
  local P = rad * 102.9372 -- perihelion of the Earth
  return M + C + P + PI
end

function sunCoords(d)
  local M = solarMeanAnomaly(d)
  local L = eclipticLongitude(M)
  return declination(L, 0), rightAscension(L, 0)
end

function suncalc(lat, lng, time)
  time = time or os.time()
  if type(time) == 'table' then
    time = os.time(time)
  end

  local lw = rad * -lng
  local phi = rad * lat
  local d = toDays(time)
  local dec, ra = sunCoords(d)
  local H = siderealTime(d, lw) - ra

  local alt, az = altitude(H, phi, dec), azimuth(H, phi, dec)
  return deg(alt), 180 + deg(az)
end


local sunAltitude, sunAzimuth = suncalc(latitude, longitude, os.time())

print(sunAltitude .. ' : ' .. sunAzimuth);
