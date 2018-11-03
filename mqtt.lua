local service_period = 60 * 1000
local service_tmr = tmr.create()
local online = false


local m_dis = {}

--Initialize MQTT client with keepalive timer
if m == nil then
  m = mqtt.Client(MQTT_CLIENTID, MQTT_KEEPALIVE, MQTT_USERNAME, MQTT_PASSWORD) 
else
  m:close()
end

--Set LWT
m:lwt('/lwt/' .. MQTT_CLIENTID, "died", 0, 0)

--Publish service data: uptime, IP, rssi
function service_pub()
  LedBlink(50)
  time = tmr.time()
  dd = time / (3600 * 24)
  hh = (time / 3600) % 24
  mm = (time / 60) % 60
  local str = string.format("%dd %dh %dm", dd, hh, mm)
  m:publish(MQTT_MAINTOPIC.."/state/uptime", str, 0, 1, nil)
  ip = wifi.sta.getip()
  if ip == nil then
      ip = "unknown"
  end
  rssi = wifi.sta.getrssi()
  if rssi == nil then
      rssi = "unknown"
  end
  m:publish(MQTT_MAINTOPIC.."/state/ip", ip, 0, 1, nil)
  m:publish(MQTT_MAINTOPIC.."/state/rssi", rssi, 0, 1, nil)
end

--When client connects, print status message and subscribe to cmd topic
function handle_mqtt_connect(m)
  --Set connection status flag
  online = true

  -- Serial status message
  print("MQTT: " .. MQTT_CLIENTID .. " connected to broker " 
    .. MQTT_HOST .. ":" .. MQTT_PORT)

  -- Subscribe to the topic where the ESP8266 will get commands from
  m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0, function (m)
    print('MQTT: subscribed to ' .. MQTT_MAINTOPIC) 
  end)

  --Publish service data periodicaly
  service_pub()
  tmr.alarm(service_tmr, service_period, tmr.ALARM_AUTO, service_pub)
  tmr.start(service_tmr)
end

--When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
  --Clear connection status flag
  online = false

  --Try to reconnect
  print ("\n\nDisconnected from broker")
  print("Heap: ", node.heap())
  tmr.stop(service_tmr)
  do_mqtt_connect()
end)

--Interpret the command
m:on("message", function(m,t,pl)
  if pl == nil then pl = "-none-" end
  print("PAYLOAD: -none-")
  print("TOPIC: " .. t)

  --remove end trailing space in the topic (if any)
  t = string.gsub(t, "%s$", "")
  
  --Run command handler
  if pl ~= nil and m_dis[t] then
      m_dis[t](m,pl)
  end
end)

--MQTT error handler
function handle_mqtt_error(client, reason)
    LedFlicker(50, 200, 5)
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

--MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker " .. MQTT_HOST ..  "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

function debounce(func)
  local last = -1

  return function (...)
    local now = tmr.now()
    if now - last < BUTTON_DEBOUNCE then return end

    last = now
    return func(...)
  end
end

-- actions
local function state_pub(m, msg)
  if online then
    m:publish(MQTT_MAINTOPIC .. '/cmd/power', msg, 0, 1)
    print("MQTT (online): " .. msg)
    LedBlink(100)
  else
    print("MQTT (offline): " .. msg)
  end
end

local function switch_power(m, pl)
	if string.lower(pl) == "on" or pl == "1" then
    gpio.write(GPIO_SWITCH, gpio.HIGH)
		print("MQTT : plug ON for ", MQTT_CLIENTID)
	elseif string.lower(pl) == "off" or pl == "0" then
		gpio.write(GPIO_SWITCH, gpio.LOW)
		print("MQTT : plug OFF for ", MQTT_CLIENTID)
	end
end

local function toggle_power()
	if gpio.read(GPIO_SWITCH) == gpio.HIGH then
		gpio.write(GPIO_SWITCH, gpio.LOW)
    state_pub(m, "off")
	else
		gpio.write(GPIO_SWITCH, gpio.HIGH)
    state_pub(m, "on")
  end
end


-- Start / Switch GPIO INIT
gpio.mode(GPIO_SWITCH, gpio.OUTPUT)
gpio.mode(GPIO_BUTTON, gpio.INT)
gpio.trig(GPIO_BUTTON, 'down', debounce(toggle_power))

--Assign MQTT handlers
m_dis[MQTT_MAINTOPIC .. '/cmd/power'] = switch_power
m_dis[MQTT_MAINTOPIC .. '/cmd/status'] = service_pub


-- Connect to the broker
do_mqtt_connect()
