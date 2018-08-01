dofile("credentials.lua")
lights = require("lights")
app = require("application")

lights.fill(0, 128, 0);

function runApplication()
  dofile("setup.lua")
end

tmr.create():alarm(3000, tmr.ALARM_SINGLE, runApplication)
