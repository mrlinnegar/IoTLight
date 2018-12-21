dofile("credentials.lua")
lights = require("lights")
app = require("network")

function runApplication()
  dofile("setup.lua")
end

tmr.create():alarm(3000, tmr.ALARM_SINGLE, runApplication)
