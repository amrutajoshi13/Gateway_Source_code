#!/bin/sh

#config_file="/usr/local/bin/Testscripts/IAB44BConfig.cfg"

source /usr/local/bin/Testscripts/IAB44BConfig.cfg
wifi_enable_disable=$(hexdump -v -n 1 -s 0x61 -e '7/1 "%01X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
wifi_enable_disable=$(echo "$wifi_enable_disable" | tr -d '\013\014\015 ')

#echo "wifi_enable_disable:$wifi_enable_disable"
if [ "$wan_mac" = "y" ]; then
	wan_mac_addr=$(hexdump -v -n 6 -s 0x2e -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
fi

lan_mac_addr=$(hexdump -v -n 6 -s 0x28 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_mac_addr=$(hexdump -v -n 6 -s 0x4 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
fi
serial_number=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
imei_n=$(hexdump -v -n 8 -s 0x110 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
imei=${imei_n:0}

if [ -e /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt ]
then 
	rm /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi

time_stamp=$(date)
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "[$time_stamp]" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The serial number is - $serial_number" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The IMEI number is - $imei" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
if [ "$wan_mac" = "y" ]; then
	echo "The wan mac addr is - $wan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi
echo "The lan mac addr is - $lan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	echo "The wifi mac addr is - $wifi_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt

#Wifi SSID 
wifi_ssid="AP_$serial_number"
wifi_guest_ssid="GUESTAP_$serial_number"


filename=${serial_number:0}.txt
board_name=$(cat /tmp/sysinfo/board_name)

outputfile2path="/usr/local/bin/Testscripts/Testresult/output2_file.txt"
#Update the required parameters in config files.
uci set boardconfig.board.serialnum=$serial_number
if [ "$wan_mac" = "y" ]; then
	uci set boardconfig.board.wanmacid=$wan_mac_addr
fi
uci set boardconfig.board.lanmacid=$lan_mac_addr
if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	uci set boardconfig.board.wifimacid=$wifi_mac_addr
	sleep 1
	uci set sysconfig.wificonfig.wifi1ssid=$wifi_ssid
	sleep 1
	uci set wireless.ap.ssid=$wifi_ssid
	uci commit wireless
	
	uci set network.ra0=interface
	uci set network.ra0.ipaddr='192.168.100.1'
	uci set network.ra0.netmask='255.255.255.0'
	uci set network.ra0.proto='static'
	uci set network.ra0.ifname='ra0'
	uci commit network
	wifi

    uci del_list rpcd.admin.read='!macidconfig'
	uci del_list rpcd.admin.write='!macidconfig'
	uci del_list rpcd.@login[2].read='!macidconfig'
	uci del_list rpcd.@login[2].write='!macidconfig'
	uci commit rpcd	
	
	#Update SSID in mt7628.dat file.
	wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
	ssid=$(grep -w "SSID1" ${wirelessdatfile})        
	ssid_replace="SSID1=$wifi_ssid"
	sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"

	ssid_guest=$(grep -w "SSID2" ${wirelessdatfile})        
	ssid_guest_replace="SSID2=$wifi_guest_ssid"
	sed -i "s/${ssid_guest}/${ssid_guest_replace}/" "$wirelessdatfile"
fi
uci set boardconfig.board.imei=$imei
uci commit boardconfig

sleep 1

cp /etc/config/boardconfig /root/InterfaceManager/config/boardconfig

uci set system.system.hostname=$serial_number
uci commit system

sleep 1

serialNum=$(uci get boardconfig.board.serialnum)
topic=$(echo "${serialNum}/connectionDiagnostics")
uci set connectionDiagnostics.general.mqttTopic="$topic"
uci commit connectionDiagnostics


sleep 1
uci set networkinterfaces.SW_LAN.macaddress=$lan_mac_addr
if [ "$wan_mac" = "y" ]; then
	uci set networkinterfaces.EWAN5.macaddress=$wan_mac_addr
	uci set network.EWAN5.macaddr=$wan_mac_addr
	uci commit networkinterfaces
fi
uci commit sysconfig
uci commit network
uci commit networkinterfaces

cp /etc/wireless/mt7628/mt7628.dat /root/InterfaceManager/mt7628/mt7628.dat

uci set system.system.hostname=$serial_number
uci commit system
cp /etc/config/boardconfig /root/InterfaceManager/config/
cp /etc/config/system /root/InterfaceManager/config/
cp /etc/config/sysconfig /root/InterfaceManager/config/
cp /etc/config/network /root/InterfaceManager/config/
cp /etc/config/networkinterfaces /root/InterfaceManager/config/
cp /etc/config/connectionDiagnostics /root/InterfaceManager/config/


/etc/init.d/system restart
sleep 1

simselect_gpio=$(uci get systemgpio.gpio.simselectgpio)

simselect_value=$(uci get systemgpio.gpio.sim2selectvalue)

reset_gpio=$(uci get systemgpio.gpio.systemresetswitch)

sim1_led_gpio=$(uci get systemgpio.gpio.Sim1LedGpio) 

sim2_led_gpio=$(uci get systemgpio.gpio.Sim2LedGpio) 

network_led_gpio=$(uci get systemgpio.gpio.networkModeLed) 

signal_strength1_gpio=$(uci get systemgpio.gpio.modem1SignalStrengthLed1) 

signal_strength2_gpio=$(uci get systemgpio.gpio.modem1SignalStrengthLed2) 

signal_strength3_gpio=$(uci get systemgpio.gpio.modem1SignalStrengthLed3) 

signal_strength4_gpio=$(uci get systemgpio.gpio.modem1SignalStrengthLed4) 

echo "wifi_enable_disable=$wifi_enable_disable" > "/usr/local/bin/Testscripts/Testresult/output_file.txt"

cat /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt  > /usr/local/bin/Testscripts/Testresult/$filename


echo "===================================================================================== 
                                   USB:Modem Test
===================================================================================== "
echo " "
res33=n
modem_status=$(lsusb -t | grep -e option | grep -o 480 |head -1)
sleep 1
if [ $modem_status = "480" ]
then
	echo -e "\e[1;32m [$time_stamp]	Modem test=PASS \e[0m"
	a=$(echo "[$time_stamp]	Modem test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res33=y
else
	echo -e "\e[1;31m [$time_stamp]	Modem test=FAIL \e[0m"
	a=$(echo "[$time_stamp]	Modem test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res33=n
fi

echo ""

echo "res33=$res33" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
sim_status=$(cat /sys/class/gpio/gpio$simselect_gpio/value)
sim_print=$(($sim_status+1))



echo "===================================================================================== 
                                SIM$sim_print QCCID TEST
===================================================================================== "

echo " "
flag=0
count=0
qccid1=""
res1=n
echo "Waiting for QCCID of sim$sim_print"
while [ $flag -eq 0 ] && [ $count -ne 10 ]
do
	sleep 2
	count_in=$(ls /dev | grep -i "ttyU" | wc -l)
	for k in $(seq 1 $count_in)
	do
		i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
        qccid1=$(gcom -d /dev/$i -s /etc/gcom/atqccid_test.gcom | head -2 |tail -1 | cut -d " " -f 2)
		
		#checking whether qccid is empty or not
		if [[ -z $qccid1 ]]
		then
				continue
		fi

		#checking whether the length of qccid is correct or not
		len_qccid1=$(echo ${#qccid1})
		if [ $len_qccid1 -eq 21 ]
		then
			time_stamp=$(date)
			res1=y
			echo -e "\e[1;32m [$time_stamp]	QCCID for sim$sim_print = $qccid1 \e[0m"
			a=$(echo "[$time_stamp]	QCCID for sim$sim_print = $qccid1" | tr -d '\013\014\015'| tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			flag=1
			break
		fi
	done
	count=$((count+1))	
	
	if [ $count -eq 10 ] && [ $flag -eq 0 ]
	then
		time_stamp=$(date)
		res1=n
		echo -e "\e[1;31m [$time_stamp]	QCCID for sim$sim_print = Not available \e[0m"
		a=$(echo "[$time_stamp]	QCCID for sim$sim_print = Not Available" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
done

echo "qccid1=$qccid1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res1=$res1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo " "
echo "=====================================================================================
		                  IMEI NUMBER ,FW_VERSION  & SIGNAL STRENGTH 
===================================================================================== "
sleep 2
res2=n
res3=n
echo " "
for temp in $(seq 1 3)
do
	count_in=$(ls /dev | grep -i "ttyU" | wc -l)
	for k in $(seq 1 $count_in)
	do
		i=$(ls /dev | grep -i "ttyU" | head -$k |tail -1)
		ec=$(/bin/at-cmd /dev/$i ati  > /usr/local/bin/Testscripts/temp.txt) 
		modem=$(cat /usr/local/bin/Testscripts/temp.txt | head -3 |tail -1 | tr -d '\013\014\015')
		modem_name=$(cat /usr/local/bin/Testscripts/temp.txt | head -2 |tail -1 | tr -d '\013\014\015')
		firmare_version=$(cat /usr/local/bin/Testscripts/temp.txt | head -4 |tail -1 | tr -d '\013\014\015')
		rm -f /usr/local/bin/Testscripts/temp.txt
	
		if [[ -z $modem ]]
		then 
			if [ $k -eq $count_in ] && [ $temp -eq 3 ]
			then 
				time_stamp=$(date)
				echo -e "\e[1;31m [$time_stamp]	AT commands = FAIL \e[0m"
				a=$(echo "[$time_stamp]	AT commands = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res2=n
			fi
				continue
		fi

		sleep 3
	
		echo " "
		for j in $(seq 1 3)
		do 
			sig_str=$(/bin/at-cmd /dev/$i at+csq | head -2 | tail -1 | cut -d " " -f 2 |cut -d "," -f 1)
			if [ $sig_str -ge 15 ]
			then
				time_stamp=$(date)
				echo "[$time_stamp]	Sim$sim_print signal strength = $sig_str " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
				echo ""
				echo -e "\e[1;32m [$time_stamp]	Sim$sim_print signal strength test = PASS \e[0m"
				a=$(echo "[$time_stamp]	Sim$sim_print signal strength test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res3=y
				break
			fi
			if [ $j -eq 3 ]
			then 
				time_stamp=$(date)
				echo "[$time_stamp]	Sim$sim_print signal strength = $sig_str " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
				echo ""
				echo -e "\e[1;31m [$time_stamp]	Sim$sim_print signal strength test = FAIL \e[0m"
				a=$(echo "[$time_stamp]	Sim$sim_print signal strength test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res3=n
				break
			fi
		done

		time_stamp=$(date)
		echo "[$time_stamp]	Modem name = $modem_name" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo "[$time_stamp]	Modem = $modem " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo "[$time_stamp]	Modem firmware version = $firmare_version" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo ""
	
		echo -e "\e[1;32m [$time_stamp]	AT commands = PASS \e[0m"
		a=$(echo "[$time_stamp]	AT commands = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res2=y
		flag=1
		break
	done
	if [ $flag -eq 1 ]
	then 
		break
	fi
done
echo "res2=$res2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res3=$res3" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo " "
echo "===================================================================================== 
                                    PING TEST
===================================================================================== "
echo " "

if [ "$ethernet1" = "y" ]; then
	res4=n
	echo "Connect to the LAN1 port."	
	echo "Pinging to 192.168.10.2 ...."

	time_stamp=$(date)
	packet=$(ping -A -I eth0.1 -c 40 192.168.10.2 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
	if [ $packet -lt 20 ]; then	
		echo -e "\e[1;32m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res4=y
	else
		echo -e "\e[1;31m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		echo "Ethernet is down! Please check the ethernet connection .. "
		res4=n
	fi
else
		res4=y
fi
echo "res4=$res4" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then
    res5=n
    echo "Connect to the LAN2 port."
    echo "Pinging to 192.168.10.3 ...."

    time_stamp=$(date)
    packet=$(ping -A -I eth0.1 -c 40 192.168.10.3 | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1)

    if [ $packet -lt 20 ]; then
        echo -e "\e[1;32m [$time_stamp] LAN1:$packet% packet loss. Ethernet 2 Ping Test = PASS \e[0m"
        a=$(echo "[$time_stamp] LAN1:$packet% packet loss. Ethernet 2 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
        res5=y
    else
        echo -e "\e[1;31m [$time_stamp] LAN1:$packet% packet loss. Ethernet 2 Ping Test = FAIL \e[0m"
        a=$(echo "[$time_stamp] LAN1:$packet% packet loss. Ethernet 2 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
        echo "Ethernet is down! Please check the ethernet connection .. "
        res5=n
    fi

else
	res5=y
fi
echo "res5=$res5" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then
	res6=n
	echo "Connect to the LAN3 port."	
	echo "Pinging to 192.168.10.4 ...."

	time_stamp=$(date)
	packet=$(ping -A -I eth0.1 -c 40 192.168.10.4 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
	if [ $packet -lt 20 ]; then	
		echo -e "\e[1;32m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 3 Ping Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 3 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res6=y
	else
		echo -e "\e[1;31m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 3 Ping Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 3 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		echo "Ethernet is down! Please check the ethernet connection .. "
		res6=n
	fi

else
	res6=y
fi
echo "res6=$res6" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then

	res7=n
	echo "Connect to the LAN4 port."	
	echo "Pinging to 192.168.10.5 ...."

	time_stamp=$(date)
	packet=$(ping -A -I eth0.1 -c 40 192.168.10.5 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
	if [ $packet -lt 20 ]; then	
		echo -e "\e[1;32m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 4 Ping Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 4 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res7=y
	else
		echo -e "\e[1;31m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 4 Ping Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 4 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		echo "Ethernet is down! Please check the ethernet connection .. "
		res7=n
	fi	
else
	res7=y
fi
echo "res7=$res7" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$ethernet1" = "y" ] && [ "$ethernet2" = "y" ]; then
	res8=n
	echo "Connect to the WAN port "
	echo "Pinging WAN port to 8.8.8.8 ...."	
	time_stamp=$(date)
	packet_usb=$(ping -A -I eth0.5 -c 40 8.8.8.8 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}' | sed 's/.\{1\}$//')
	if [ $packet_usb -lt 10 ]; then	
		echo -e "\e[1;32m [$time_stamp] WAN:$packet_usb% packet loss. WAN port Ping Test = PASS \e[0m"
		a=$(echo "[$time_stamp]  WAN:$packet_usb% packet loss. WAN port Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res8=y;
	else
		echo -e "\e[1;31m [$time_stamp] WAN:$packet_usb% packet loss. WAN port Ping Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]  WAN:$packet_usb% packet loss. WAN port Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res8=n;
	fi
else
	res8=y
fi
echo "res8=$res8" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo " "
echo "===================================================================================== 
                                   MODEM PING TEST
===================================================================================== "
echo " "
res9=n

flag=0
packet_usb=100
ip_check=192
for j in $(seq 5)
do
	count=$(ls /dev | grep -i "ttyU" | wc -l)
	for k in $(seq 1 $count)
	do 
		i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
		ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1)
		ec1=$(/bin/at-cmd /dev/$i ati | head -3 | tail -1 | tr -d '\011\012\013\014\015')
		if [[ -z $ec1 ]]
		then 
			continue
		fi
		
		ec1=${ec1:2:2}

		if [ $ec1 -eq 05 ] || [ $ec1 -eq 25 ]; then
			echo "Pinging wwan0 to 8.8.8.8 ...."
			packet_usb=$(ping -A -I wwan0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			ip_check=$(ifconfig wwan0 | grep -i "inet addr" | tr -d " " | cut -d ":" -f 2 | cut -d "." -f 1)
			flag=1		
			break
		else
			echo "Pinging USB0 to 8.8.8.8 ...."		
			packet_usb=$(ping -A -I usb0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			ip_check=$(ifconfig usb0 | grep -i "inet addr" | tr -d " " | cut -d ":" -f 2 | cut -d "." -f 1)
			flag=1
			break
		fi
	done
	if [ "$flag" -eq "1" ]
	then
		break
	fi
done
time_stamp=$(date)
if [ $packet_usb -lt 10 ]; then	
	echo -e "\e[1;32m [$time_stamp] MODEM:$packet_usb% packet loss. Modem Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	MODEM:$packet_usb% packet loss. Modem Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res9=y;
else
	echo -e "\e[1;31m [$time_stamp] MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res9=n;
fi

if [ $ip_check -eq 192 ]
then 
	echo "Raw ip did not set"
	echo "do the add_macaadr test again " 
	echo "exiting script"
	exit 0
fi


if [ $sim_status -eq 1 ]
then
	sim_status=0
else
	sim_status=1
fi
sim_print=$(($sim_status+1))

echo "res9=$res9" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"




if [ "$DualSim" = "y" ]; then

echo " "

echo "=====================================================================================
                                SWITCHING TO SIM$sim_print
====================================================================================="
echo""
echo $sim_status > /sys/class/gpio/gpio$simselect_gpio/value 
sleep 2
echo 1 > /sys/class/gpio/gpio$simselect_value/value  
sleep 3
echo 0 > /sys/class/gpio/gpio$simselect_value/value 
sleep 5

flag=0
count=0

echo "=====================================================================================
                                  SIM$sim_print QCCID TEST
======================================================================================"
res10=n
echo "Waiting for QCCID of sim$sim_print"
while [ $flag -eq 0 ] && [ $count -ne 25 ]
do
	count_in=$(ls /dev | grep -i "ttyU" | wc -l)
	sleep 2
	for k in $(seq 1 $count_in)
	do
		i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
		qccid2=$(gcom -d /dev/$i -s /etc/gcom/atqccid_test.gcom | head -2 |tail -1 | cut -d " " -f 2)
		
		#checking whether qccid is empty or not
			if [[ -z $qccid2 ]]
			then
					continue
			fi

		#In case of error 
		
			if [ "$qccid2" = "open" ]
			then
                continue
			fi
        	
		len_qccid2=$(echo ${#qccid2})
        
		time_stamp=$(date)
		if [ "$qccid1" != "$qccid2" ] && [ $len_qccid2 -eq 21 ]
		then 
			echo "[$time_stamp]	QCCID for sim$sim_print = $qccid2" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo -e "\e[1;32m [$time_stamp] Sim switching through gpio test = SUCCESS \e[0m"
			a=$(echo "[$time_stamp]	Sim switching through gpio test = SUCCESS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			flag=1
			res10=y
			break
		else
			continue
		fi
	done
	count=$((count+1))	
done

if [ "$res10" = "n" ]
then
	echo -e "\e[1;31m [$time_stamp] Sim switching through gpio test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	Sim switching through gpio test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res10=n
fi

else
res10=y
fi
echo "qccid2=$qccid2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res10=$res10" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
  

if [ "$rtc_test" = "y" ]; then
echo " "
echo "=====================================================================================
		                           RTC TEST 
===================================================================================== "
	res11=n
	hwclock -w
	for i in $(seq 1 1000)
	do
		sys_time=$(date | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
		rtc_time=$(/sbin/hwclock -r | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)

		if [ "$sys_time" = "$rtc_time" ]
		then 
			res11=y
			break
		fi
	done
	time_stamp=$(date)
	if [ "$res11" = "y" ]
	then
		echo -e "\e[1;32m [$time_stamp]	RTC test = PASS \e[0m"
		a=$(echo "[$time_stamp]	RTC test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	else
		echo -e "\e[1;31m [$time_stamp]	RTC test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	RTC test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
	rtc_value=$(hwclock -r | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
	echo "rtc_value=\"$rtc_value\"" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
else
	res11=y
fi
echo "res11=$res11" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "

if [ "$switch_test" = "y" ]; then
echo " "
echo "=====================================================================================
				              SWITCH TEST 
===================================================================================== "
	echo " "
	echo " "
	echo "Whether need to Continue Reset switch test? (y/n) "
	#read reset
	read -p "Whether need to Continue Reset switch test? (y/n) " reset

	sleep 1
	if [ "$reset" = "y" ]; then
		echo "Testing switch"
		echo "Press and hold switch to observe the change in values"
		res12=n
		for i in $(seq 1 25);
		do
			gpio_val=$(cat /sys/class/gpio/gpio$reset_gpio/value)
			echo $gpio_val
			if [ $gpio_val -eq 0 ]
			then
				res12=y
				time_stamp=$(date)
				echo -e "\e[1;32m [$time_stamp] Reset Switch test = PASS \e[0m"					
				a=$(echo "[$time_stamp]	Reset Switch Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				break
			fi
			sleep 1
		done
	fi	

		if [ "$res12" = "n"  ]
		then
			time_stamp=$(date)
			echo -e "\e[1;31m [$time_stamp] Reset Switch test = FAIL \e[0m"
			a=$(echo "[$time_stamp]	Reset Switch Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		fi
else
	res12=y
fi
echo "res12=$res12" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
echo " "
echo "=====================================================================================
				               WIFI TEST 
===================================================================================== "
	res13=n
	echo " "
	echo "Connect to WIFI Access point on the Phone & check the signal strength on WIfiman app."
	echo "Enter the signal strength --"
	read sigstr

	echo " "
	echo " "
	time_stamp=$(date)
	if [ $sigstr -lt 35 ]; then	
		echo -e "\e[1;32m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res13=y;
	else
		echo -e "\e[1;31m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res13=n;
	fi
else
	res13=y
fi
echo "res13=$res13" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$led_test" = "y" ]; then
echo " "
echo " "
echo "=====================================================================================
                                  LED TEST
===================================================================================== "
#turning on sim1 and sim2 and 5g LED


	echo 1 > /sys/class/gpio/gpio$signal_strength1_gpio/value

	echo 1 > /sys/class/gpio/gpio$signal_strength2_gpio/value

	echo 1 > /sys/class/gpio/gpio$signal_strength3_gpio/value

	echo 1 > /sys/class/gpio/gpio$signal_strength4_gpio/value

	sleep 3

	echo 0 > /sys/class/gpio/gpio$sim1_led_gpio/value
 
	echo 0 > /sys/class/gpio/gpio$sim2_led_gpio/value

	echo 0 > /sys/class/gpio/gpio$network_led_gpio/value

	echo 0 > /sys/class/gpio/gpio$signal_strength1_gpio/value

	echo 0 > /sys/class/gpio/gpio$signal_strength2_gpio/value

	echo 0 > /sys/class/gpio/gpio$signal_strength3_gpio/value

	echo 0 > /sys/class/gpio/gpio$signal_strength4_gpio/value

	sleep 2

	echo "Whether all the LED's(Status and eternet LED's) are glowing or not? (y/n)"
	read res14

	time_stamp=$(date)
	if [ "$res14" = "y" ]
	then 
		echo -e "\e[1;32m [$time_stamp]	LED test = PASS \e[0m"
		a=$(echo "[$time_stamp]	LED test = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	else
		echo -e "\e[1;31m [$time_stamp]	LED test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	LED test = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
else
	res14=y
fi
echo "res14=$res14" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$rs485_test" = "y" ]; then

echo " "
echo "====================================================================================="
echo "                               RS485 TEST "
echo "===================================================================================== "

	res15=n
	. /root/RS485UtilityComponent/etc/Config/RS485utilityConfigTestScript.cfg
	. /usr/local/bin/Testscripts/testscriptconfig.cfg
	retry=0
	RS485_out=$(sh /bin/hextoIEEE.sh "$slaveid_rs485")
	ieee754_value=$(echo "$RS485_out" | grep -o 'IEEE 754 Value:[+-]\?[0-9]\+\(\.[0-9]\+\)\?' | cut -d':' -f2)

	echo "IEEE 754 Value=$ieee754_value"

	if echo "$RS485_out" | grep -q "not"; then
		res15="n"
	else
		res15="y"
	fi

	time_stamp=$(date)
	case $res15 in
		[yY]* )
			echo -e "\e[1;32m  [$time_stamp]  RS485 test = PASS \e[0m" 				
			a=$(echo "[$time_stamp]	RS485 test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)		
			res15=y; break;;
		[nN]* )
			echo -e "\e[1;31m  [$time_stamp]  RS485 test = FAIL \e[0m" 				
			a=$(echo "[$time_stamp]	RS485 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res15=n; break;;
		* ) ;;
	esac
else
	res15=y
fi
echo "res15=$res15" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$rs232_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                              RS232 TEST "
echo "===================================================================================== "

	. /root/RS232UtilityComponent/etc/Config/RS232utilityConfig.cfg 
	. /usr/local/bin/Testscripts/testscriptconfig.cfg


	res16=n                                
	echo -e "\e[34mPLEASE CHECK LOOPBACK IS CONNECTED OR NOT? (y/n) \e[0m"
	read res16

	if [ "$res16" = "y" ]; then
		retry_count=0
		rs232Out=$(/root/RS232UtilityComponent/RS232UtilityGD44 "$deviceid_rs232")
		hex_line=$(echo "$rs232Out" | grep -o 'hex values:.*')
		hex_values=$(echo "$hex_line" | cut -d ':' -f 2)

		hex_values_no_spaces=$(echo "$hex_values" | tr -d ' ')
		echo "Received_value:$hex_values_no_spaces"

		if echo "$hex_values_no_spaces" | grep -q '[^0]'; then
			echo -e "\e[1;32m [$time_stamp] RS232 test = PASS \e[0m"
			a=$(echo "[$time_stamp]  RS232 test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res17=y
		else	
			echo -e "\e[1;31m [$time_stamp] RS232 test = FAIL \e[0m"
			a=$(echo "[$time_stamp]  RS232 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res17=n
		fi
	else 
		echo "There is no RS232 in this Board"
		echo -e "\e[1;31m [$time_stamp] RS232 test = FAIL \e[0m"
		a=$(echo "[$time_stamp]  RS232 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res16=n
	fi
else
	res16=y
	res17=y
fi
echo "res16=$res16" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res17=$res17" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$do_test" = "y" ]; then

echo " "
echo "====================================================================================="
echo "                             DigitalOutput TEST "
echo "===================================================================================== "


	DO_output=$(sh /bin/DOUtility.sh)

	res18=n
	if echo "$DO_output" | grep -q "but"; then
		res18="n"
	else
		res18="y"
	fi

	time_stamp=$(date)
	case $res18 in
		[yY]* )
			echo -e "\e[1;32m  [$time_stamp]  DigitalOutput test = PASS \e[0m" 				
			a=$(echo "[$time_stamp]	DigitalOutput test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res18=y;
			break;;
		[nN]* )
			echo -e "\e[1;31m  [$time_stamp]  DigitalOutput test = FAIL \e[0m"
			a=$(echo "[$time_stamp]	DigitalOutput test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res18=n; break;;
		* ) ;;
	esac
else
	res18=y
fi
echo "res18=$res18" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$di_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                             DigitalInput TEST "
echo "===================================================================================== "
	dido_num=$(uci get digitalinputconfig.didogpioconfig.numberOfDido)
	gpio1=$(uci get digitalinputconfig.didogpioconfig.di1)
	gpio2=$(uci get digitalinputconfig.didogpioconfig.di2)
	gpio3=$(uci get digitalinputconfig.didogpioconfig.di3)
	gpio4=$(uci get digitalinputconfig.didogpioconfig.di4)
	sleep 2
	if [ "$dido_num" -eq 4 ] || [ "$dido_num" -eq 2 ]; then
		echo "Please make switch 1 High "
		sleep 2
     
		DI_Input=$(sh /bin/DIUtility.sh 1)

		if [ "$DI_Input" = "DI1 - GPIO Pin Number-$gpio1 = 1" ]; then
			res19=y
			echo -e "\e[1;32m Yes \e[0m" 	
		else
			res19=n 
			echo -e "\e[1;31m No \e[0m"             
		fi
		#echo "res19:$res19"
	
		sleep 5
		echo "Please make switch 2 High "
	
		sleep 2
		DI_Input=$(sh /bin/DIUtility.sh 2)

		if [ "$DI_Input" = "DI2 - GPIO Pin Number-$gpio2 = 1" ]; then
			res20=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res20=n   
			echo -e "\e[1;31m No \e[0m"         
		fi
	
		sleep 5
	fi
	
	if [ "$dido_num" -eq 4 ]; then
		
		
		echo "Please make switch 3 High "
		sleep 2
		DI_Input=$(sh /bin/DIUtility.sh 3)

		if [ "$DI_Input" = "DI3 - GPIO Pin Number-$gpio3 = 1" ]; then
			res21=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res21=n 
			echo -e "\e[1;31m No \e[0m"            
		fi
		#echo "res21:$res21"
	
		sleep 5
		echo "Please make switch 4 High "
		sleep 2
		DI_Input=$(sh /bin/DIUtility.sh 4)

		if [ "$DI_Input" = "DI4 - GPIO Pin Number-483 = 1" ]; then
			res22=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res22=n
			echo -e "\e[1;31m No \e[0m" 
		fi
		#echo "res22:$res22"
	else
		res21=y
		res22=y
	fi
	sleep 3
	if [ "$dido_num" -eq 4 ] || [ "$dido_num" -eq 2 ]; then
		echo "Please make switch 1 low"

		sleep 2
		DI_Input=$(sh /bin/DIUtility.sh 1)

		if [ "$DI_Input" = "DI1 - GPIO Pin Number-$gpio1 = 0" ]; then
			
			res23=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res23=n    
			echo -e "\e[1;31m No \e[0m"          
		fi

		sleep 2
	
		echo "Please make switch 2 low"
		sleep 2

		DI_Input=$(sh /bin/DIUtility.sh 2)

		if [ "$DI_Input" = "DI2 - GPIO Pin Number-$gpio2 = 0" ]; then
			res24=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res24=n     
			echo -e "\e[1;31m No \e[0m"         
		fi

	fi
		
	if [ "$dido_num" -eq 4 ]; then
		sleep 2
		echo "Please make switch 3 low"
		sleep 2
	
		DI_Input=$(sh /bin/DIUtility.sh 3)

		if [ "$DI_Input" = "DI3 - GPIO Pin Number-$gpio3 = 0" ]; then
			res25=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res25=n 
			echo -e "\e[1;31m No \e[0m"               
		fi

		sleep 2
		echo "Please make switch 4 low"
		sleep 2
	
		DI_Input=$(sh /bin/DIUtility.sh 4)

		if [ "$DI_Input" = "DI4 - GPIO Pin Number-$gpio4 = 0" ]; then
			res26=y
			echo -e "\e[1;32m Yes \e[0m"
		else
			res26=n   
			echo -e "\e[1;31m No \e[0m"        
		fi

		time_stamp=$(date)
	else
		res25=y
		res26=y
	fi
	if [ "$res19" = "y" ] && [ "$res20" = "y" ] && [ "$res21" = "y" ] && [ "$res22" = "y" ] && [ "$res23" = "y" ] && [ "$res24" = "y" ] && [ "$res25" = "y" ] && [ "$res26" = "y" ] ; then
		echo -e "\e[1;32m  [$time_stamp]  DigitalInput test = PASS \e[0m"
		a=$(echo "[$time_stamp]	DigitalInput test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)	
		res27=y	  
	else
		echo -e "\e[1;31m  [$time_stamp]  DigitalInput test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	DigitalInput test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res27=n
	fi
else
	res19=y
	res20=y
	res21=y
	res22=y
	res23=y
	res24=y
	res25=y
	res26=y
	res27=y
fi
echo "res19=$res19" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res20=$res20" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res21=$res21" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res22=$res22" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res23=$res23" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res24=$res24" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res25=$res25" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res26=$res26" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res27=$res27" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$ai_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                               AI TEST "
echo "===================================================================================== "




	FILE="/usr/local/bin/Testscripts/calibout.txt"
# Check if the file exists
	if [ -f "$FILE" ]; then
		# Read the content of the file
		STATUS=$(cat "$FILE")
    
		case "$STATUS" in
			*"Calibration Failed"*)
				echo "Calibration Test = FAIL."
				a=$(echo "[$time_stamp]	Calibration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				echo "\033[38;5;214mPlease Run the Calibration Script.\033[0m\n" 
				sleep 5
				res38="n"
				;;
			*"Calibration Successful"*)
				echo "Calibration was successful."
				printf "\033[38;5;214mCalibration Success.\033[0m\n" 
				a=$(echo "[$time_stamp]	Calibration Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res38="y"

				;;
			*)
				echo "Unknown calibration status." 
				a=$(echo "[$time_stamp]	Calibration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res38="n"	
				;;
		esac
	else
		echo "Calibration file not found."
		a=$(echo "[$time_stamp]	Calibration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res38="n" 
	
	fi

	
output_file="/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res38=$res38" >> "$output_file"


		
. /usr/local/bin/Testscripts/testscriptconfig.cfg
	
	> /usr/local/bin/Testscripts/out.txt

	ChannelNumber=$(uci get "analoginputconfig.analoginputconfig.NoOfInputs")
	all_passed=true # Assume all tests pass initially

		for ADCChannelNumber in $(seq 1 "$ChannelNumber"); do
			ADC=$(sh /bin/AIOutility.sh "$ADCChannelNumber")
			result_var="res$((39 + ADCChannelNumber))"
			channel_type=$(uci get "analoginputconfig.analoginputconfig.ChannelType$ADCChannelNumber")

			if [[ "$channel_type" == "1" ]]; then
				current_value=$(echo "$ADC" | awk '{print $2}')
				
				echo -e "Current value for AI$ADCChannelNumber = $current_value mA" 
				echo -e "Current value for AI$ADCChannelNumber = $current_value mA" >> /usr/local/bin/Testscripts/out.txt
			else
				voltage_value=$(echo "$ADC" | awk '{print $2}')
				echo -e "Voltage value for AI$ADCChannelNumber = $voltage_value V"
				echo -e "Voltage value for AI$ADCChannelNumber = $voltage_value V" >> /usr/local/bin/Testscripts/out.txt
			fi

			# Determine if the test passes or fails for this channel
			if echo "$ADC" | grep -q "not present"; then
				eval "$result_var='n'"
				all_passed=false
			elif echo "$ADC" | grep -q "ADCChannelNumber should only accept"; then
				eval "$result_var='n'"
				all_passed=false
			else
				eval "$result_var='y'"
			fi

			sleep 5
		done
	time_stamp=$(date)

		# Final test result based on $all_passed
		if $all_passed; then
			echo -e "\e[1;32m [$time_stamp] AnalogInput test = PASS \e[0m"
			echo "[$time_stamp]  AnalogInput test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			res30="y"
		else
			echo -e "\e[1;31m [$time_stamp] AnalogInput test = FAIL \e[0m"
			echo "[$time_stamp]  AnalogInput test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			res30="n"
		fi


		# Default values for other results
		res28="y"
		res29="y"

# Append results to the output file


else
	res30="y"
        res28="y"
        res29="y"
fi

output_file="/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res28=$res28" >> "$output_file"
echo "res29=$res29" >> "$output_file"
echo "res30=$res30" >> "$output_file"



if [ "$usb_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                             USB TEST "
echo "===================================================================================== "
	

	usb_out=$(ls /dev/sda)

	if [ "$usb_out" = "/dev/sda" ]
	then
		res31=y
	else
		res31=n
	fi 
	time_stamp=$(date)
	if [ "$res31" = "y" ]
	then 
		echo -e "\e[1;32m [$time_stamp]	USB test = PASS  \e[0m"
		a=$(echo "[$time_stamp]	USB test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		
	else
		
		echo -e "\e[1;31m [$time_stamp]	USB test = FAIL  \e[0m"
		a=$(echo "[$time_stamp]	USB test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		
	fi	    
else
	res31=y
fi
echo "res31=$res31" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
if [ "$emmc_test" = "y" ]; then


echo " "
echo "=====================================================================================
                                      eMMC card Test
===================================================================================== "
	
emmc_test=n
echo "Do you want to perform eMMC card test (y/n)"
read res32
	
if [ "$res32" = "y" ]; then
	emmc_test=y
	echo "Check whether eMMC card is inserted or not? (y/n)"
	read res34
		
	if [ "$res34" = "y" ]; then
		echo "Testing eMMC Card"
		out=$(ls /dev/mmcblk0)

		if [ "$out" = "/dev/mmcblk0" ]; then 
			res35=y
		else
			res35=n
		fi 
	else		
		res35=n
	fi
	    
	time_stamp=$(date)
	#if [ "$res35" = "y" ]
	if [ "$res32" = "y" ] && [ "$res34" = "y" ] && [ "$res35" = "y" ] ; then
	
		echo -e "\e[1;32m [$time_stamp]	eMMC Card test = PASS  \e[0m"
		a=$(echo "[$time_stamp]	eMMC Card test = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		
	else
		echo -e "\e[1;31m [$time_stamp]	eMMC Card test = FAIL  \e[0m"
		a=$(echo "[$time_stamp]	eMMC Card test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
else
	echo -e "\e[1;32m [$time_stamp] eMMC card test is not Enabled... \e[0m"                                            
    a=$(echo "[$time_stamp]  eMMC card test is not Enabled" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res32=y
	res34=y
	res35=y
	emmc_test=n
fi
else
	res32=y
	res34=y
	res35=y
	fi
echo "emmc_test=$emmc_test" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res32=$res32" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res34=$res34" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res35=$res35" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$nms_test" = "y" ]; then

echo "=====================================================================================                                            
                                 NMS Registration Test                                                                                 
===================================================================================== "    
echo " "    
counter=1    
nms_test=n                                                                              
register_message="NMS is not enabled"
result_logged=false     
time_stamp=$(date)           

while [ $counter -le 3 ]; do                                                               
    echo "Do you want to register NMS (y/n)"                                                  
    read res36                                                                                
                                                                                                                                          
    case $res36 in                                                                         
        y)                                                                                                          
            source /usr/local/bin/Testscripts/Nmssecuritykey.txt 
            nms_test=y                                                                              
            nms_out=$(/usr/local/bin/Testscripts/Register_NMS.sh "$URL" "$KEY")                                 
            tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')    
            sleep 20                                                                                                         
            if [ -n "$tunip" ]; then                                                                                                          
				echo -e "\e[1;32m [$time_stamp] NMS Registration Test = PASS \e[0m"                                                   
               # a=$(echo "[$time_stamp]  NMS Registration Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
                register_message="NMS Registration Test = PASS"
                res36=y      
                echo "nms_url=$URL" >> "$outputfile2path"                                     
				echo "tunip=$tunip" >> "$outputfile2path"                                                                              
                break                                                                                  
            else                                                                                                      
				echo -e "\e[1;31m [$time_stamp] NMS Registration Test = FAIL \e[0m"                                            
                #a=$(echo "[$time_stamp]  NMS Registration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
                register_message="NMS Registration Test = FAIL"
                res36=n  
            fi                                                                                                        
            ;;                                                                                                        
        n)                                                                                                            
            echo -e "\e[1;32m [$time_stamp] NMS is not Enabled... \e[0m"
            register_message="NMS is not enabled"  
            #a=$(echo "[$time_stamp]  NMS is not enabled" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)                            
            res36=y   
            nms_test=n                                                                                               
            break                                                                           
            ;;                                                                                                        
        *)                                                                                                            
            echo "Please enter a valid value (y/n)."                                                                                          
            ;;                                           
    esac                                                                                                                                   
                                                                                                        
    counter=$((counter + 1))                                                                                                                  
done 

if [ "$result_logged" = false ]; then
    a=$(echo "[$time_stamp]  $register_message" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
    result_logged=true
fi       
       
  else
  res36=y
  fi                  
echo "nms_test=$nms_test" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"                                                                                 
echo "res36=$res36" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"        

time_stamp=$(date)

echo "=====================================================================================
                                 BOARD POWERING OFF 
====================================================================================="
echo -e "\e[1;32m Press Enter after 10 seconds to continue the test.Board is rebooting... \e[0m"
sleep 3
sh /root/usrRPC/script/Board_Recycle_12V_Script.sh



