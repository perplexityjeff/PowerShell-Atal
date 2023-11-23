# PowerShell-Atal
A PowerShell module to more easily automate ATAL / Comet Systems sensor administration. The main reason for creating this was to automate and sync time (NTP) settings and the offset because of daylight saving. I ended creating multiple little scripts for various other purposes. 

Website: https://www.atal.nl/

Website: https://www.cometsystem.com/

I have no affliation with ATAL or Comet Systems other than being a customer / end user of their sensors.

# Usage
* You can use the Get-AtalSensors scripts with for example parameter 192.168.0.1. This will scan the IP range 192.168.0.1 to 254 and look for ATAL sensors. It will output the IP address, name, serial number and firmware version. 

`$sensors = Get-AtalSensors -StartIP 192.168.0.1`

* You can also easily export and import this to an XML file using built-in PowerShell functions. 

`$sensors | Export-Clixml C:\sensors.xml`

`$sensors = Import-Clixml C:\sensors.xml`

* All our sensors are protected using an username and password combination as such all commands to actually make modifications requires you to use an encoded version of these credentials to do more work. To more easily do this you can use Get-AtalCredential with a username and password and it will output the correct credential object to use in the scripts.  

`$cred = Get-AtalCredential -Username 'admin' -Password 'password'`

* After you have a list of sensors and an credential object you can start doing modifications using the IP address of the sensor and the credential object.

`Set-AtalSensorTime -SensorIP 192.168.0.20 -TimeServer ntp.time.nl -TimeOffset 60 -AtalCredential $cred`

* You can also combine commands into each other so in our case we wanted to change all the sensors within an IP range to use a specific NTP server and a time offset.

`$sensors | Select-Object -ExpandProperty SensorIP | Set-AtalSensorTime -TimeServer ntp.time.nl -TimeOffset 60 -AtalCredential $cred`

# WIP
This repo is still a work in progress, I will work on it as I go. Currently this is not a module yet as I am still working on the scripts. So far all the scripts work with the ethernet sensors that we have within the company. 

# Pull Requests
Feel free to submit Pull Requests, I will work on it and upload changes as I go but if you see any improvements that can be made feel free to suggest them.

# Learning
I am still and will always be learning. Do not expect perfection and feel free to send feedback :). 
