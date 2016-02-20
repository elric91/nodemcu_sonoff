-- file : broker.lua

local dispatcher = {}
local switch_gpio = 6
local light_gpio = 7


-- client activation
m = mqtt.Client(MQTT_CLIENTID, 60, "", "") -- no pass !


-- actions
local function set_current(m, pl)
	print("action : activate ")
	if pl == "on" then
		gpio.write(switch_gpio, gpio.HIGH)
		gpio.write(light_gpio, gpio.LOW)
		print("plug on")
	else
		gpio.write(switch_gpio, gpio.LOW)
		gpio.write(light_gpio, gpio.HIGH)
		print("plug off")
	end
end

local function set_light(m, pl)
	print("action : activate ")
	if pl == "off" then
		gpio.write(light_gpio, gpio.HIGH)
		print("plug off")
	else
		gpio.write(light_gpio, gpio.LOW)
		print("plug on")
	end
end


-- dispatching
dispatcher[MQTT_MAINTOPIC .. '/set_current'] = set_current 
dispatcher[MQTT_MAINTOPIC .. '/set_light'] = set_light


-- event : last will
m:lwt('/lwt', MQTT_CLIENTID .. " died !", 0, 0)

-- event : connect
m:on('connect', function(m)
	print('\n*************************', MQTT_CLIENTID, " connected to : ", MQTT_HOST, " on port : ", MQTT_PORT, '\n*************************\n')
	m:subscribe(MQTT_MAINTOPIC .. '/#', 0, function (m)
		print('Subscribed to : ', MQTT_MAINTOPIC) 
	end)
end)


-- event : disconnect
m:on('offline', function(m)
	print('Disconnected from : ', MQTT_HOST)
	print('Heap : ', node.heap())
end)

-- event : receive msg
m:on('message', function(m, topic, pl)
	print('	payload : ', pl)
	print('	topic : ', topic)

	if pl~=nil and dispatcher[topic] then
		dispatcher[topic](m, pl)
	end
end)



-- Start
-- connect gpios
gpio.mode(switch_gpio, gpio.OUTPUT)
gpio.mode(light_gpio, gpio.OUTPUT)
-- connect mqtt
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
-- loop

