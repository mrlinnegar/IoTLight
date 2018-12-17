local module = {}

local BYTES_PER_BULB = 3
local NUMBER_OF_BULBS = 16


function hexToColor(hex)
 local r = tonumber(string.sub(hex, 1, 2), 16);
 local g = tonumber(string.sub(hex, 3, 4), 16);
 local b = tonumber(string.sub(hex, 5, 6), 16);
 return {g,r,b};
end

function module.fillHex(hex)
  color = hexToColor(hex);
  fillBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  fillBuffer:fill(color[1], color[2], color[3])
  ws2812.write(fillBuffer)
end

function module.fillRGB(red, green, blue)
  fillBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  fillBuffer:fill(red, green, blue)
  ws2812.write(fillBuffer);
end


function module.clear()
  clearBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  clearBuffer:fill(0,0,0)
  ws2812.write(clearBuffer)
end

ws2812.init();
return module;
