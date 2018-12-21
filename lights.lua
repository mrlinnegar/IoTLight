local module = {}

local BYTES_PER_BULB = 3
local FRAMES_PER_SECOND = 16
local NUMBER_OF_BULBS = 16

local frames = {}
local currentFrame = 1
local animation = nil

local numberOfFrames = 16;
local currentColor = {0,0,0}

local function animate()
  color = frames[currentFrame];
  fillBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  fillBuffer:fill(color[1], color[2], color[3])
  ws2812.write(fillBuffer);

  currentFrame = currentFrame + 1;

  if(currentFrame > numberOfFrames) then
    currentFrame = numberOfFrames;
  end
end

function hexToColor(hex)
 local r = tonumber(string.sub(hex, 1, 2), 16);
 local g = tonumber(string.sub(hex, 3, 4), 16);
 local b = tonumber(string.sub(hex, 5, 6), 16);
 return {g,r,b};
end


local function createSequence( targetColor )
  newFrames = {}

  rIndex = ((targetColor[1] - currentColor[1]) / FRAMES_PER_SECOND);
  gIndex = ((targetColor[2] - currentColor[2]) / FRAMES_PER_SECOND);
  bIndex = ((targetColor[3] - currentColor[3]) / FRAMES_PER_SECOND);


  for index=1,FRAMES_PER_SECOND do
    frame = { currentColor[1] + (rIndex * index), currentColor[2] + (gIndex * index), currentColor[3] + (bIndex * index) };
    newFrames[index] = frame;
  end

  currentColor = targetColor
  currentFrame = 1

  frames = newFrames
end


function module.clear()
  clearBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  clearBuffer:fill(0,0,0)
  ws2812.write(clearBuffer)
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


function module.fillHex(hexString)
  color = hexToColor(hex)
  createSequence(color)
  start()
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

ws2812.init();
return module;
