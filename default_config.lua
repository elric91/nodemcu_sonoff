-- GPIO table
GPIO16 = 0 --read/write only
GPIO5 = 1
GPIO4 = 2
GPIO0 = 3
GPIO2 = 4
GPIO14 = 5
GPIO12 = 6
GPIO13 = 7
GPIO15 = 8 --wired to GND
GPIO3 = 9 --RX
GPIO1 = 10 --TX
--GPIO9 = 11 - unusable on ESP-12 module (SPI flash pin)
--GPIO10 = 12 - unusable on ESP-12 module (SPI flash pin)

-- GPIOS
GPIO_LED = GPIO13
GPIO_SWITCH = GPIO12
GPIO_BUTTON = GPIO0

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
MQTT_KEEPALIVE = 60

-- OTHERS
BUTTON_DEBOUNCE = 500000
TELNET_MODULE = 1 -- 1 to activate
HTTP_MODULE = 1 -- 1 to activate (OTA and http page)


-- Confirmation message
print("\nGlobal variables loaded...\n")
