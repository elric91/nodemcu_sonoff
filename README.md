# nodemcu_sonoff
Some nodemcu based code to run sonoff wifi enabled plugs through MQTT

1. **config.lua :** as it name implies
2. **init.lua :** runs the wifi connection and launches ota and broker modules
3. **ota.lua :** web server (http) and over the air updates module
```
echo -e "**LOAD**\npage.tmpl" | cat -  page.tmpl | socat -u stdin TCP:ipaddress:80 -- updates the page.tmpl file on device
echo "**RESTART**" | socat -u stdin TCP:ipaddress:80 -- restart esp8266
```
4. **broker.lua :** mqtt client module
```
mosquitto_pub -h "myMQTTserver" -t "/myMQTTpath/power" -m "on" -- turn plug on
mosquitto_pub -h "myMQTTserver" -t "/myMQTTpath/power" -m "off" -- turn plug off
```
