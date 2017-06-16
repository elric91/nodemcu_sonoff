local dispatcher = {}

-- client activation
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

-- debounce
function debounce(func)
    local last = 0
    local delay = 500000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

-- actions
local function switch_power(m, pl)
	if pl == "on" then
		gpio.write(GPIO_SWITCH, gpio.HIGH)
		print("MQTT : plug ON for ", MQTT_CLIENTID)
	else
		gpio.write(GPIO_SWITCH, gpio.LOW)
		print("MQTT : plug OFF for ", MQTT_CLIENTID)
	end
end

local function toggle_power()
	if gpio.read(GPIO_SWITCH) == gpio.HIGH then
		gpio.write(GPIO_SWITCH, gpio.LOW)
		m:publish(MQTT_MAINTOPIC .. '/power', "off", 0, 1)
	else
		gpio.write(GPIO_SWITCH, gpio.HIGH)
		m:publish(MQTT_MAINTOPIC .. '/power', "on", 0, 1)
    end
end

-- events
m:lwt('/lwt', MQTT_CLIENTID .. " died !", 0, 0)

m:on('connect', function(m)
	print('MQTT : ' .. MQTT_CLIENTID .. " connected to : " .. MQTT_HOST .. " on port : " .. MQTT_PORT)
	m:subscribe(MQTT_MAINTOPIC .. '/#', 0, function (m)
		print('MQTT : subscribed to ', MQTT_MAINTOPIC) 
	end)
end)

m:on('offline', function(m)
	print('MQTT : disconnected from ', MQTT_HOST)
end)

m:on('message', function(m, topic, pl)
	print('MQTT : Topic ', topic, ' with payload ', pl)
	if pl~=nil and dispatcher[topic] then
		dispatcher[topic](m, pl)
	end
end)


-- Start
gpio.mode(GPIO_SWITCH, gpio.OUTPUT)
gpio.mode(GPIO_BUTTON, gpio.INT)
gpio.trig(GPIO_BUTTON, 'down', debounce(toggle_power))
dispatcher[MQTT_MAINTOPIC .. '/power'] = switch_power
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
