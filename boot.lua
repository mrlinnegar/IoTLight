dofile("credentials.lua")
lights = require("lights")
app = require("network")

function runApplication()
  dofile("setup.lua")
end
lights.fillRGB(128,0,0)
tmr.create():alarm(3000, tmr.ALARM_SINGLE, runApplication)
