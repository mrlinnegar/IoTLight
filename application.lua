local module = {}

local m = nil

local function send_ping()
    m:publish("/connect",node.chipid() .. "|" .. lights.currentColor(),0,0)
end

local function subscribe_all()
    m:subscribe("/color", 0, function(client) end)
end

local function do_mqtt_connect()
    m = mqtt.Client(node.chipid(), 120)

    m:on("message", function(conn, topic, message)
      if message ~= nil then
        instruction, hex = message:match("([^|]+)|(.+)");
        if instruction == "C" then
          print(hex)
          lights.fill(hex)
        else
          print("no message")
          --lights.stop()
          --lights.clear()
        end
      end
    end)

    m:connect(BROKER_ENDPOINT , BROKER_PORT, 0, function(client)
      client:subscribe('/' .. node.chipid(), 0, function(client)
        subscribe_all()
        tmr.stop(6)
        tmr.alarm(6, 5 * 1000, 1, send_ping)
      end)
    end,
    handle_mqtt_error)

end

function handle_mqtt_error(client, reason)
  print("Client not connected: " .. reason)
  tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function module.start()
    do_mqtt_connect()
end

function module.update()
   send_ping()
end
return module;
