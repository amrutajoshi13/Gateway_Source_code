#!/bin/sh

# Check if URL and secret key are provided as arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <URL> <NMS_Key>"
    exit 1
fi

url=$1
nms_key=$2

    # Setting up NMS and VPN
    uci set remoteconfig.general.rmsoption="nms"
    uci set remoteconfig.nms.nmsenable="1"
    uci commit remoteconfig
    sleep 2
	uci set remoteconfig.nms.httpurl="$url"
	uci set remoteconfig.general.rmsoption="nms"
	uci commit remoteconfig
    uci set vpnconfig1.general.enableopenvpngeneral="1"
    uci commit vpnconfig1
    sleep 2

    # Configuring openwisp
    uci set openwisp.http.url="$url"
    uci set openwisp.http.shared_secret="$nms_key"
    uci commit openwisp
    sleep 2
	
    # store key
    touch /root/oldnmskey
    oldkey=$(grep "option shared_secret" /etc/config/openwisp | awk -F"'" '{print $2}')
    echo "$oldkey" > /root/oldnmskey
    sleep 3

    # Restarting services
    /etc/init.d/openwisp_config restart
    sleep 10
    /etc/init.d/openvpn restart
    sleep 10
    /etc/init.d/openwisp-monitoring restart

    sleep 40

    UUID=$(uci get openwisp.http.uuid)
    KEY=$(uci get openwisp.http.key)
    if [ ! -z "$UUID" ] && [ ! -z "$KEY" ]; then
        echo "Device update for uuid & key "
    fi

    uci show openwisp.http.uuid
    uci show openwisp.http.key

    # Loop to check every 30 seconds, with a maximum of 6 iterations
    i=0
while [ $i -lt 6 ]; do
    tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')
    if [ -n "$tunip" ]; then
        echo " Device registered  Connection successful!.."
        break  
    else
        echo "IP address not found. Checking again in 30 seconds..."
        sleep 30
    fi
    i=$((i+1))
done

    # Check if IP address was not found after 4 iterations
    if [ -z "$tunip" ]; then
        echo "Connection failed. Retrying..."
    fi



