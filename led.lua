UNLIM_FLICK = 0xFFFF

local ledOn = false
local flkr_cnt = 0
local flkr_pause = 0
local flkr_pulse = 0
local flkr_state = 0

-- Set LED state ON
function LedOn()
    gpio.write(GPIO_LED, gpio.LOW)
    ledOn = true
end

-- Set LED state OFF
function LedOff()
    gpio.write(GPIO_LED, gpio.HIGH)
    ledOn = false
end

-- Single LED blink
function LedBlink(ms)
    LedOn()
    tmr.alarm(WIFI_LED_BLINK_ALARM_ID, ms, tmr.ALARM_SINGLE, LedOff)
    flkr_state = 0
end

-- Toggle LED state
function LedToggle()
    if ledOn then
        LedOff()
    else
        LedOn()
    end
end

-- Flicker timer callback
local function Flick(t)
    local delay = 0
    
    if flkr_cnt <= 0 then 
        flkr_state = 0
        return
    end
    if flkr_state == 1 then
        flkr_state = 2
        LedOn()
        delay = flkr_pulse
    elseif flkr_state == 2 then
        LedOff()
        flkr_state = 1
        delay = flkr_pause
        if flkr_cnt ~= UNLIM_FLICK then
            flkr_cnt = flkr_cnt - 1
        end
    end
    tmr.alarm(t, delay, tmr.ALARM_SINGLE, Flick)
end

-- Run LED flicker
function LedFlicker(pulse, pause, count)
    if count > 0  then
        flkr_cnt = count
        if pulse < 50 then pulse = 50 end
        if pause < 50 then pause = 50 end
        flkr_pause = pause
        flkr_pulse = pulse
        if flkr_state == 0 then
            flkr_state = 1
            Flick(WIFI_LED_BLINK_ALARM_ID)
        end
    end
end

-- Disable LED flicker
function LedFlickerStop()
    flkr_state = 0
    tmr.unregister(WIFI_LED_BLINK_ALARM_ID)
    LedOff()
end

-- Configure LED
gpio.mode(GPIO_LED, gpio.OUTPUT)
LedOff()
