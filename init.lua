-- init all globals
function load_lib(fname)
    if file.open(fname .. ".lc") then
        file.close()
        dofile(fname .. ".lc")
    else
        dofile(fname .. ".lua")
    end
end

load_lib("config")

local wifiReady = 0
local firstPass = 0
local ledOn = false

function configureWiFi()
    gpio.mode(GPIO_LED, gpio.OUTPUT)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_SSID, WIFI_PASS)
    tmr.alarm(WIFI_ALARM_ID, 2000, 1, wifi_watch)
end

function wifi_watch() 
    
    status = wifi.sta.status()
    -- only do something if the status actually changed (5: STATION_GOT_IP.)
    if status == 5 and wifiReady == 0 then
        wifiReady = 1
        print("WiFi: connected with " .. wifi.sta.getip())
        load_lib("broker")
    elseif status == 5 and wifiReady == 1 then
        if firstPass == 0 then
            load_lib("ota")
            firstPass = 1
            tmr.stop(WIFI_LED_BLINK_ALARM_ID)
            turnWiFiLedOn()
        end
    else
        wifiReady = 0
        turnWiFiLedOnOff()
        print("WiFi: (re-)connecting")

    end
end

function turnWiFiLedOnOff()
    tmr.alarm(WIFI_LED_BLINK_ALARM_ID, 200, 0, function()
        if ledOn then
            turnWiFiLedOff()
        else
            turnWiFiLedOn()
        end
    end)
end
function turnWiFiLedOn()
    gpio.write(GPIO_LED, gpio.LOW)
    ledOn = true
end
function turnWiFiLedOff()
    gpio.write(GPIO_LED, gpio.HIGH)
    ledOn = false
end

-- Configure
configureWiFi()