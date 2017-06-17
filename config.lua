-- GPIOS
GPIO_LED = 7
GPIO_SWITCH = 6
GPIO_BUTTON = 3

-- WiFi networks list in format [SSID] = password
WIFI_AUTH = {
["YOUR_SSID_1"] = "YOUR PASSWORD 1",
["YOUR_SSID_2"] = "YOUR PASSWORD 2"
}

-- Alarms
WIFI_ALARM_ID = 0
WIFI_LED_BLINK_ALARM_ID = 1

-- MQTT
MQTT_CLIENTID = "plugxxx"
MQTT_HOST = "YOUR_HOST"
MQTT_PORT = 1883
MQTT_MAINTOPIC = "YOUT MQTT_TOPIC" .. MQTT_CLIENTID
MQTT_USERNAME = ""
MQTT_PASSWORD = ""

-- Confirmation message
print("\nGlobal variables loaded...\n")
