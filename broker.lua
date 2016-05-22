local dispatcher = {}

-- client activation
m = mqtt.Client(MQTT_CLIENTID, 60, "", "") -- no pass !

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
dispatcher[MQTT_MAINTOPIC .. '/power'] = switch_power
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)