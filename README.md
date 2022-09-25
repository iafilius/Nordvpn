# Nordvpn

## Info regarding forked version by iafilius

- fixed some obvious small bugs in script to make it work for import
  - backup xz set permission error
  - changed compare x with xaff to x !=x$aff
  - set download url to todays location
  - removed space in variable assignment
- set default import location to the udpvpn definitions  dir
- beware of the cleanup/delete feature as it removes ALL of your VPN's (including non nordvpn)
- nmcli might get overloaded, see journalctl -xe
- Some site ID's have short name, while others full FQDN like, not sure why _yet_

## General info

- By importing all vpn sites, about 5000, the network manager on desktop gets extremely slow
you probably just don't want that.

## Script for batch importing ovpn files from NordVPN .

###Example
Get Configuration files from current dir.

```./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd"````
or

Get configuration form local direcotry "-d"

          
```./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd" -d Download/configs/```
         
Get configuration from nordvpn.com
          
```./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd" -g```
            
if you want clean configuration
          
``` ./importnordvpn -c```
            
clean configuration (remove all vpn's from nmcli ). and load new
          
```./importnordvpn -c -u "myemail@exampl.com" -p "P44SSwoRd" -d Download/configs/```

More information -h 

       
###Effect :
![alt tag](https://consolechars.files.wordpress.com/2017/02/nordvpn-gnome.gif)
---

