# nodemcu_sonoff
Some nodemcu based code to run sonoff wifi enabled plugs through MQTT
The button on the device can also be used to toggle the state of the plug
Main difference with jesstr (https://github.com/jesstr/nodemcu_sonoff) fork :
- on this one : power status and command are available in the same topic /cmd/power (useful when multiple remotes should stay in sync)
- on jesstr's one : command is on /cmd/power and status on /state/power


# How To
Clone the repo
Symlink esptool.py and luatool.py (available on github) in the main repo
copy default_config.py, rename it to config.py and update it according to your needs
execute install.sh


# Files
* **config.lua :** as its name implies
* **init.lua :** runs the wifi connection and launches ota and broker modules
* **http.lua :** web server (http) and over the air updates module
```
echo -e "**LOAD**\npage.tmpl" | cat -  page.tmpl | socat -u stdin TCP:ipaddress:80 -- updates the page.tmpl file on device
echo "**RESTART**" | socat -u stdin TCP:ipaddress:80 -- restart esp8266
```
* **mqtt.lua :** mqtt client module
```
mosquitto_pub -h "myMQTTserver" -t "/myMQTTpath/power" -m "on" -- turn plug on
mosquitto_pub -h "myMQTTserver" -t "/myMQTTpath/power" -m "off" -- turn plug off
```

> Sonoff pin layout and GPIOs stolen from [Pete and the community](http://tech.scargill.net/itead-slampher-and-sonoff/)  
> Wifi connection loop stolen from [marcelstoer/wifi-watch.lua](https://gist.github.com/marcelstoer/63ce6e6d78cef435d2ec)  
> nodemcu firmware generated with [Marcel's NodeMCU custom build machine](http://nodemcu-build.com/) (just add MQTT to the standard module selection)  
> Correction of shameful bugs,  multi-wifi enabled, install script and other stuff by [jesstr](https://github.com/jesstr), thank you !
