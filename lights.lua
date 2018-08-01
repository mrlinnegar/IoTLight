local module = {}

local BYTES_PER_BULB = 3
local SEQUENCE_FRAMES = 8
local DEFAULT_FRAMES_PER_SECOND = 8
local NUMBER_OF_BULBS = 16

local frames = {}
local currentFrame = 1
local animation = nil

local framesPerSecond = DEFAULT_FRAMES_PER_SECOND;
local numberOfFrames = SEQUENCE_FRAMES;
local loop = false;
local currentColor = "~~~"; --all off

local function createFrame(colorString)
  buffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB);
  buffer:fill(0, 0, 0);
  color = decompressColor(colorString)
  buffer:fill(color[1], color[2], color[3]);
  return buffer
end

local function animate()
  buffer = frames[currentFrame];
  ws2812.write(buffer);

  currentFrame = currentFrame + 1;

  if(currentFrame > numberOfFrames) then
    if(loop == true) then
        currentFrame = 1;
    else
        currentFrame = numberOfFrames;
    end
  end
end

function decompressColor(color)
  local r = ((color:byte(1) - 32) * 2);
  local g = ((color:byte(2) - 32) * 2);
  local b = ((color:byte(3) - 32) * 2);
  return { g, r, b };
end

function hexToColor(hex)
 local r = tonumber(string.sub(hex, 1, 2), 16);
 local g = tonumber(string.sub(hex, 3, 4), 16);
 local b = tonumber(string.sub(hex, 5, 6), 16);
 return {g,r,b};
end

function module.validateSequence(frameCount, sequence)
  return (sequence:len() % frameCount == 0)
end

function module.createSquence( shouldLoop, frameCount, frameRate, sequence)
  newFrames = {}

  for index=1,frameCount do
    frame = sequence:sub(((index * BYTES_PER_BULB) - (BYTES_PER_BULB-1)), index * BYTES_PER_BULB)
    newFrames[index] = createFrame(frame);
  end

  currentColor = frame

  if(frameRate > 64) then
    framesPerSecond = 64;
  else
    framesPerSecond = frameRate;
  end
  currentFrame = 1;
  numberOfFrames = frameCount;
  loop = shouldLoop;
  frames = newFrames;

end

function module.fill(green, red, blue)
  fillBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  fillBuffer:fill(green, red, blue)
  ws2812.write(fillBuffer);
end


function module.clear()
  clearBuffer = ws2812.newBuffer(NUMBER_OF_BULBS, BYTES_PER_BULB)
  clearBuffer:fill(0,0,0)
  ws2812.write(clearBuffer)
end

function module.start()
  if(animation) then
    animation:unregister();
  end

  if(currentFrame == numberOfFrames) then
    currentFrame = 1;
  end

  animation = tmr.create()
  animation:register(1000 / framesPerSecond, tmr.ALARM_AUTO, animate)
  animate(); -- draw the first frame
  animation:start()
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
