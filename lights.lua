local module = {}

local BYTES_PER_BULB = 3
local FRAMES_PER_SECOND = 32
local NUMBER_OF_BULBS = 16

local frames = {}
local currentFrame = 1
local animation = nil

local numberOfFrames = FRAMES_PER_SECOND;
local currentColor = {0,0,0}

local function animate()
  color = frames[currentFrame];
  fillBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  fillBuffer:fill(color[2], color[1], color[3])
  ws2812.write(fillBuffer);
  currentFrame = currentFrame + 1;

  if(currentFrame > numberOfFrames) then
    currentFrame = numberOfFrames;
  end
end

local function hexToColor(hex)
 local r = tonumber(string.sub(hex, 1, 2), 16);
 local g = tonumber(string.sub(hex, 3, 4), 16);
 local b = tonumber(string.sub(hex, 5, 6), 16);
 return {r, g, b};
end


local function rgbToHex(rgb)
    local hexadecimal = ''

    for key, value in pairs(rgb) do
        hexadecimal = hexadecimal .. value .. ','
    end

    return hexadecimal
end

local function lerp(a, b, u)
  return (1-u) * a + u * b;
end

local function createSequence( targetColor )
  newFrames = {}

  for index=1,FRAMES_PER_SECOND do
    r = lerp( currentColor[1], targetColor[1], index / FRAMES_PER_SECOND);
    g = lerp( currentColor[2], targetColor[2], index / FRAMES_PER_SECOND);
    b = lerp( currentColor[3], targetColor[3], index / FRAMES_PER_SECOND);

    frame = { r, g, b };
    newFrames[index] = frame;
  end

  currentColor = targetColor
  currentFrame = 1

  frames = newFrames
end

local function validateHex ( hexString )
  return (hexString:len() == 6)
end

local function start()
  if(animation) then
    animation:unregister();
  end

  animation = tmr.create()
  animation:register(1000 / FRAMES_PER_SECOND, tmr.ALARM_AUTO, animate)
  animate(); -- draw the first frame
  animation:start()
end

function module.clear()
  clearBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  clearBuffer:fill(0,0,0)
  ws2812.write(clearBuffer)
end

function module.fillHex(hexString)
  if(validateHex(hexString)) then
    color = hexToColor(hex)
    createSequence(color)
    start()
  end
end

function module.fillRGB(red, green, blue)
  color = {red, green, blue }
  createSequence(color)
  start()
end

function module.stop()
  if(animation) then
    animation:unregister();
  end
end

function module.currentColor()
  return currentColor
end

function module.handleMessage(message)
  instruction, hex = message:match("([^|]+)|(.+)");
  if instruction == "C" then
    module.fillHex(hex)
  end
end

function module.getTopic()
  return "/color"
end

function module.getUpdate()
  return rgbToHex(currentColor)
end

ws2812.init();
return module;
