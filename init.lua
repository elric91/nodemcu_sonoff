-- init all globals
function load_lib(fname)
    if file.open(fname .. ".lc") then
        file.close()
        dofile(fname .. ".lc")
    else
        dofile(fname .. ".lua")
    end
end

-- get table length
function tablelen(table)
    local n = 0
    for _ in pairs(table) do
            n = n + 1
    end
    return n
end

load_lib("config")

local ssid, pass = nil
local wifiReady = 0
local firstPass = 0
local ledOn = false

-- connect to WIFI network(s) from SSID list
function connectWiFi(ssid_list)
    for k,v in pairs(WIFI_AUTH) do
        if ssid_list[k] then
                ssid, pass = k, v
                break
        end
    end
    if ssid ~= nil then
        print("Connecting to "..ssid)
        wifi.sta.config(ssid, pass)
        tmr.alarm(WIFI_ALARM_ID, 2000, tmr.ALARM_AUTO, wifi_watch)
    else
        print("SSID not found")
    end
end

-- configure WIFI network
function configureWiFi()
    gpio.mode(GPIO_LED, gpio.OUTPUT)
    wifi.setmode(wifi.STATION)
    if tablelen(WIFI_AUTH) > 1 then
        -- scan available networks
        wifi.sta.getap(connectWiFi)
    else
        -- connect to the predefined SSID
        connectWiFi(WIFI_AUTH)
    end
end

-- WIFI connection status checking
function wifi_watch()
    status = wifi.sta.status()
    -- only do something if the status actually changed
    if status == wifi.STA_GOTIP and wifiReady == 0 then
        wifiReady = 1
        print("WiFi: connected with " .. wifi.sta.getip())
        if TELNET == 1 then
            load_lib("telnet")
        end
        load_lib("broker")
    elseif status == wifi.STA_GOTIP and wifiReady == 1 then
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
    tmr.alarm(WIFI_LED_BLINK_ALARM_ID, 200, tmr.ALARM_SINGLE, function()
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
