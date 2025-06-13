#!/bin/sh

source /usr/local/bin/Testscripts/IAB44BConfig.cfg


if [ "$usb_test" = "y" ]; then
	productId=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/1-1.1/idProduct)
	vendorid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/1-1.1/idVendor)
else
	productid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idProduct)
	vendorid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idVendor)
fi

board_name=$(cat /tmp/sysinfo/board_name)
#board_name="Silbo_IAB44-C_GW"
flag=0

if  [ "$productid" != "030e" ]; then
	
	for k in $(seq 5)
	do
	count=$(ls /dev | grep "ttyU" | wc -l)

		for j in $(seq 1 $count)
		do
			i=$(ls /dev | grep "ttyU" | head -$j | tail -1)
			ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1) 
	
			ec1=$(/bin/at-cmd /dev/$i ati | head -3 | tail -1 | tr -d '\011\012\013\014\015')

			if [[ -z $ec1 ]]
			then 
				continue
			fi

			if [ "$ec1" = "EM05-G" ]; then
				flag=1
				break
			fi
	

			ec1=${ec1:2:2}
			if [ $ec1 -eq 20 ]
			then
				setrawip=$(gcom -d /dev/$i -s /etc/gcom/setrawip.gcom | grep -i "OK")
				if [[ -n $setrawip ]]
				then 
					flag=1
					break
				fi
			fi

		done
		if [ $flag -eq 1 ]
		then 
			break
		fi
	done

fi

flag1=0

for k in $(seq 3)
do
count=$(ls /dev | grep "ttyU" | wc -l)
flag1=0
for j in $(seq 1 $count)
do
	i=$(ls /dev | grep "ttyU" | head -$j | tail -1)
	ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1) 
	if [[ -z $ec1 ]]
	then 
		continue
	fi
	ec1=${ec1:2:2}
		SetHotSwap=$(/bin/at-cmd /dev/$i at+qsimdet=1,1 | grep -i "QSIMDET")
		SetHotSwapresp=$(/bin/at-cmd /dev/$i at+qsimdet?) 
		if [[ -n "$SetHotSwapresp" ]]
		then 
		    flag1=1
			break
		fi
	
 done
	 if [ $flag1 -eq 1 ]; then
        break 
	 fi
done

serial_number=$(grep "serial_number" /usr/local/bin/Testscripts/Testresult/user_entry.txt | cut -d "=" -f 2 | tr -d '[:space:]')
#lanmac=$(grep -i -o 'lan2_mac_id: [0-9a-fA-F-]\{17\}' /usr/local/bin/Testscripts/Testresult/user_entry.txt | sed 's/lan2_mac_id: //')
#wan1mac=$(grep -i -o 'lan1_mac_id: [0-9a-fA-F-]\{17\}' /usr/local/bin/Testscripts/Testresult/user_entry.txt | sed 's/lan1_mac_id: //')
lanmac=$(grep -o -i 'lan2_mac_id: [0-9a-fA-F:]\{17\}' /usr/local/bin/Testscripts/Testresult/user_entry.txt | sed 's/lan2_mac_id: //')
wan1mac=$(grep -o -i 'lan1_mac_id: [0-9a-fA-F:]\{17\}' /usr/local/bin/Testscripts/Testresult/user_entry.txt | sed 's/lan1_mac_id: //')
wifimac=$(grep -o -i 'lan10_mac_id: [0-9a-fA-F:]\{17\}' /usr/local/bin/Testscripts/Testresult/user_entry.txt | sed 's/lan10_mac_id: //')

#echo "Enter serial number"
#read serial_number
#echo "Serial Number : $serial_number" > /root/ConfigFiles/Logs/boardconfig.txt

#echo "LAN MAC ID : $lanmac" >> /root/ConfigFiles/Logs/boardconfig.txt
#if [ "$wan_mac" = "y" ]; then
	#echo "Enter Wan MAC address - "
	#read wan1mac
	#echo "WAN MAC ID : $wan1mac" >> /root/ConfigFiles/Logs/boardconfig.txt
#fi

#echo "Enter LAN/WAN MAC address - " 
#read lanmac

echo "Serial number is $serial_number "
echo "wan MAC address is $wan1mac"
echo "lan MAC address is $lanmac"
#echo "wifi MAC address is $wifimac"


echo "Do you want to enter WIFI MAC Address(y/n)"
read  wifienabledisable
if [ $wifienabledisable = "y" ]
then
    echo "wifi MAC address is $wifimac"
    sed -i 's|//wifi_enable_disable:true,|wifi_enable_disable:true,|g' /www/luci2/view/configuration.network.js
    wifienabledisable=1

	echo "WIFI MAC ID : $wifimac" >> /root/ConfigFiles/Logs/boardconfig.txt
else
	uci delete network.ra0
	uci commit network
	wifi
 	uci add_list rpcd.admin.read='!macidconfig'
	uci add_list rpcd.admin.write='!macidconfig'
	uci add_list rpcd.@login[2].read='!macidconfig'
	uci add_list rpcd.@login[2].write='!macidconfig'
	uci commit rpcd
	cp /etc/config/rpcd /root/InterfaceManager/config/
	cp /etc/config/network /root/InterfaceManager/config/
	sed -i 's|wifi_enable_disable:true,|//wifi_enable_disable:true,|g' /www/luci2/view/configuration.network.js
    wifienabledisable=0 
    uci set sysconfig.sysconfig.wifi1enable=0
    uci commit sysconfig
fi

        #to set hostname
uci set system.system.hostname=$serial_number
uci commit system

echo "======================================================================
	:Whitelabel_logo
======================================================================= "
echo " "
echo "Do you want Whitelabel_logo ?(y/n)"
read logo 

if [ $logo = "y" ]
then 
	echo "Please choose below option"
	echo "1)Web page with Default Silbo logo"
	echo "2)Web page without logo"
	echo "3)Web page with Custom logo"
	
fi
    read Value
	case $Value in 
	1)
        cp  /Web_page/custom_logo/Silbo/custom_logo.svg /www/luci2/icons/
		 # Uncomment the logo image tag in luci2.html
        echo "Uncommenting the logo image tag in luci2.html..."
        sed -i 's|<!--<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />-->|<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />|g' /www/luci2.html

        # Uncomment the logo appending line in ui.js
        echo "Uncommenting the logo appending line in ui.js..."
        sed -i 's|//\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|g' /www/luci2/ui.js

       if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
	   then
			if [ "$wifienabledisable" = "0" ]; then 
			 	if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EC200A
					uci set boardconfig.board.model="$board_name"-EC200A
				 fi
				 if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EC200A
					uci set boardconfig.board.model="$board_name"-EC200A
				 fi
			else
				uci set system.system.model="$board_name"-EC200A
				uci set boardconfig.board.model="$board_name"-EC200A
			fi
				
		elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
		then
		
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EC25E
					uci set boardconfig.board.model="$board_name"-EC25E
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EC25E
					uci set boardconfig.board.model="$board_name"-EC25E
				fi
			else
				uci set system.system.model="$board_name"-EC25E
				uci set boardconfig.board.model="$board_name"-EC25E
			fi
			cp /Web_page/EC25E/* /www/luci2/
		elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
		then  
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')					
					uci set system.system.model="$board_name"-RM500U
					uci set boardconfig.board.model="$board_name"-RM500U
					uci set signalstrength.modem1.highestNetworkMode="5g"
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-RM500U
					uci set boardconfig.board.model="$board_name"-RM500U
					uci set signalstrength.modem1.highestNetworkMode="5g"
				fi
			else
				 uci set system.system.model="$board_name"-RM500U
				 uci set boardconfig.board.model="$board_name"-RM500U
				 uci set signalstrength.modem1.highestNetworkMode="5g"
			fi
		elif [ "2c7c" = "${vendorid}" ] && [ "030e" = "${productid}" ]   
		then  
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EM05G
					uci set boardconfig.board.model="$board_name"-EM05G	
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EM05G
					uci set boardconfig.board.model="$board_name"-EM05G	
				fi
			else
				uci set system.system.model="$board_name"-EM05G
				uci set boardconfig.board.model="$board_name"-EM05G	
			fi
		
			
		elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
		then 
			if [ "$wifienabledisable" = "0" ]; then
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-RM500Q
					uci set boardconfig.board.model="$board_name"-RM500Q
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-RM500Q
					uci set boardconfig.board.model="$board_name"-RM500Q
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
					
			 else
				 uci set system.system.model="$board_name"-RM500Q
				 uci set boardconfig.board.model="$board_name"-RM500Q
				 uci set signalstrength.modem1.highestNetworkMode="5g"
				 cp /Web_page/EC25E/* /www/luci2/
			fi
			
		fi
            uci commit system
           uci commit boardconfig	     
	      cp /etc/config/system /root/InterfaceManager/config/
	      cp /etc/config/boardconfig /root/InterfaceManager/config/             
		/etc/init.d/uhttpd restart
        break
	;;
      2)
		 # Comment out the logo image tag in luci2.html
        echo "Commenting out the logo image tag in luci2.html..."
        sed -i 's|<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />|<!--<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />-->|g' /www/luci2.html

        # Comment out the logo appending line in ui.js
        echo "Commenting out the logo appending line in ui.js..."
        sed -i 's|\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|//\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|g' /www/luci2/ui.js

		
		if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
	    then
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EC200A
					uci set boardconfig.board.model="$board_name"-EC200A
				 fi
				 if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EC200A
					uci set boardconfig.board.model="$board_name"-EC200A
				 fi
			else
				uci set system.system.model="$board_name"-EC200A
				uci set boardconfig.board.model="$board_name"-EC200A
			fi
				
		elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
		then
		
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EC25E
					uci set boardconfig.board.model="$board_name"-EC25E
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EC25E
					uci set boardconfig.board.model="$board_name"-EC25E
				fi
			else
				uci set system.system.model="$board_name"-EC25E
				uci set boardconfig.board.model="$board_name"-EC25E
			fi
			cp /Web_page/EC25E/* /www/luci2/
		elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
		then  
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')					
					uci set system.system.model="$board_name"-RM500U
					uci set boardconfig.board.model="$board_name"-RM500U
					uci set signalstrength.modem1.highestNetworkMode="5g"
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-RM500U
					uci set boardconfig.board.model="$board_name"-RM500U
					uci set signalstrength.modem1.highestNetworkMode="5g"
				fi
			else
				 uci set system.system.model="$board_name"-RM500U
				 uci set boardconfig.board.model="$board_name"-RM500U
				 uci set signalstrength.modem1.highestNetworkMode="5g"
			fi
		elif [ "2c7c" = "${vendorid}" ] && [ "030e" = "${productid}" ]   
		then  
			if [ "$wifienabledisable" = "0" ]; then 
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-EM05G
					uci set boardconfig.board.model="$board_name"-EM05G	
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-EM05G
					uci set boardconfig.board.model="$board_name"-EM05G	
				fi
			else
				uci set system.system.model="$board_name"-EM05G
				uci set boardconfig.board.model="$board_name"-EM05G	
			fi
		
			
		elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
		then 
			if [ "$wifienabledisable" = "0" ]; then
				if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
					board_name=$(echo "$board_name" | sed 's/./0/10')
					uci set system.system.model="$board_name"-RM500Q
					uci set boardconfig.board.model="$board_name"-RM500Q
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
				if echo "$board_name" | grep -qE "(Silbo_IA44|IE44)";then
					board_name=$(echo "$board_name" | sed 's/./0/9')
					uci set system.system.model="$board_name"-RM500Q
					uci set boardconfig.board.model="$board_name"-RM500Q
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
					
			 else
				 uci set system.system.model="$board_name"-RM500Q
				 uci set boardconfig.board.model="$board_name"-RM500Q
				 uci set signalstrength.modem1.highestNetworkMode="5g"
				 cp /Web_page/EC25E/* /www/luci2/
			 fi
			
		fi
        uci commit system
		uci commit boardconfig	     
		cp /etc/config/system /root/InterfaceManager/config/
		cp /etc/config/boardconfig /root/InterfaceManager/config/	                          
		/etc/init.d/uhttpd restart
        break
	;;
	  3)
		# Uncomment the logo image tag in luci2.html
        echo "Uncommenting the logo image tag in luci2.html..."
        sed -i 's|<!--<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />-->|<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />|g' /www/luci2.html

        # Uncomment the logo appending line in ui.js
        echo "Uncommenting the logo appending line in ui.js..."
        sed -i 's|//\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|g' /www/luci2/ui.js
               
		/etc/init.d/uhttpd restart
        break
	;;
    * );;
esac



uci commit system
uci commit boardconfig

SerialNumber()
{
	local var1=${serial_number:0:2}
	local var2=${serial_number:2:2}
	local var3=${serial_number:4:2}
	local var4=${serial_number:6:2}
	local var5=${serial_number:8:2}
	local var6=${serial_number:10:1}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x100))
}

Wan1MAC()
{
	local var1=${wan1mac:0:2}
	local var2=${wan1mac:3:2}
	local var3=${wan1mac:6:2}
	local var4=${wan1mac:9:2}
	local var5=${wan1mac:12:2}
	local var6=${wan1mac:15:2}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x2e))
}

LANMAC()
{
	local var1=${lanmac:0:2}
	local var2=${lanmac:3:2}
	local var3=${lanmac:6:2}
	local var4=${lanmac:9:2}
	local var5=${lanmac:12:2}
	local var6=${lanmac:15:2}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x28))
}

Wifimac()
{
	local var1=${wifimac:0:2}
	local var2=${wifimac:3:2}
	local var3=${wifimac:6:2}
	local var4=${wifimac:9:2}
	local var5=${wifimac:12:2}
	local var6=${wifimac:15:2}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x4))
}

LOGO()
{
    local var1=${Value:0:2}	
    	printf "\x$var1" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x60))

}

Wifienabledisable()
{
    local var1=${wifienabledisable:0:2}	
    	printf "\x$var1" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x61))

}

IMEI()
{
	flag=0
	for k in $(seq 1 5)
	do
		count=$(ls /dev | grep "ttyU" | wc -l)
		for j in $(seq 1 $count)
		do
			i=$(ls /dev | grep "ttyU" | head -$j | tail -1)
			Imei_num=$(gcom -d /dev/$i -s /etc/gcom/atgsn_test.gcom | awk 'NR==2' | tr -d '\011\012\013\014\015\040')

			if [[ -z $Imei_num ]]
			then
				continue
			else
				echo "The IMEI number is -- $Imei_num"
				
				echo "Whether the entered IMEI number is correct or not?(y/n)" 
				read res
				
				if [ "$res" = "n" ]
				then 
					continue
				else				
					flag=1
					echo "IMEI : $Imei_num" >> /root/ConfigFiles/Logs/boardconfig.txt
					break
				fi
			fi
		done
		if [ $flag -eq 1 ]
		then 
			break
		fi
	done
	
	Imei=$Imei_num
	local var1=${Imei:0:2}
	local var2=${Imei:2:2}
	local var3=${Imei:4:2}
	local var4=${Imei:6:2}
	local var5=${Imei:8:2}
	local var6=${Imei:10:2}
	local var7=${Imei:12:2}
	local var8=${Imei:14:1}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x110))
	
}



if [ $serial_number ]
then
	dd if=/dev/mtd2 of=/tmp/factory.bin
	source /root/Web_page/Board_info.txt
	SerialNumber
	Wan1MAC
	LANMAC
	Wifienabledisable
	Wifimac
	IMEI
	LOGO
	#writing sys time to rtc time
	hwclock -w	
	max_retries=3
	retry_count=0
	while [ $retry_count -lt $max_retries ]; do
		sh /root/usrRPC/script/Recycle_WAN1_PWR_Script.sh
		
		if [ $? -eq 0 ]; then
			echo "Modem powered off successfully"
			break
		else
			echo "Modem powered off failed.Retring..."
			retry_count=$((retry_count+1))
			sleep 2
		fi
	done
	sleep 2	
	echo -e "\e[1;32m Press Enter after 10 seconds.Board is Rebooting... \e[0m"
	sleep 2
	mtd -r write /tmp/factory.bin factory
	
else
	echo "Please enter the correct values"
fi
