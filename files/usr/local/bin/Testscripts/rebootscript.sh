#!/bin/sh

source /usr/local/bin/Testscripts/Testresult/output_file.txt

source /usr/local/bin/Testscripts/IAB44BConfig.cfg
source /usr/local/bin/Testscripts/testscriptconfig.cfg


RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
outputfilepath="/usr/local/bin/Testscripts/Testresult/output_file.txt"
outputfile2path="/usr/local/bin/Testscripts/Testresult/output2_file.txt"
mac_path="/usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt"
imei=$(cat "$mac_path" | grep "The IMEI number is" | cut -d "-" -f 2)
#wifi_mac_addr=$(cat "$mac_path" | grep "The wifi mac addr is" | cut -d "-" -f 2)
serial_number_line=$(grep "The serial number is" "$mac_path")
serial_number=$(echo "$serial_number_line" | awk '{print $NF}')
filename=${serial_number:0}.txt
test_status="NA"
test_status1="Not Enabled"
file="/usr/local/bin/Testscripts/Testresult/$filename"
aifile="/usr/local/bin/Testscripts/out.txt"
calibresfile="/usr/local/bin/Testscripts/current_resistance.txt"
customer_name=$customer_name



echo " "
echo "===================================================================================== 
                                    DEVICE REBOOT TEST
===================================================================================== " 



uptime=$(awk '{print $1}' /proc/uptime)
echo "$uptime"
time_stamp=$(date)
res37=n
if [ $(awk -v uptime="$uptime" 'BEGIN {print (uptime < 180) ? "1" : "0"}') -eq 1 ]; then
	echo -e "\e[1;32m [$time_stamp]  Reboot Test = PASS \e[0m" 
    a=$(echo "[$time_stamp]  Reboot Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res37=y
	result="PASS"
     
else
	echo -e "\e[1;31m [$time_stamp]	 Reboot Test = FAIL \e[0m"
    a=$(echo "[$time_stamp]  Reboot Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res37=n
	result="FAIL"
fi
echo "Reboot Test=$result" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "=====================================================================================                                                   
                                 BOARD TEST                                                                                                   
====================================================================================="  
if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ] && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ] && [ "$res16" = "y" ] && [ "$res17" = "y" ] && [ "$res18" = "y" ] && [ "$res19" = "y" ] && [ "$res20" = "y" ] && [ "$res21" = "y" ] && [ "$res22" = "y" ] && [ "$res23" = "y" ] && [ "$res24" = "y" ] && [ "$res25" = "y" ] && [ "$res26" = "y" ] && [ "$res27" = "y" ] && [ "$res28" = "y" ] && [ "$res29" = "y" ] && [ "$res30" = "y" ] && [ "$res31" = "y" ] && [ "$res32" = "y" ] && [ "$res33" = "y" ] && [ "$res34" = "y" ] && [ "$res35" = "y" ] && [ "$res36" = "y" ] && [ "$res37" = "y" ];  then
 
	echo -e "\e[1;32m [$time_stamp]	Board Test status = PASS \e[0m"
    a=$(echo -e "[$time_stamp]	Board Test status = Pass" | tee -a "/usr/local/bin/Testscripts/Testresult/$filename")
	
else
    echo -e "\e[1;31m [$time_stamp]	Board Test status = FAIL \e[0m"
	a=$(echo "[$time_stamp]	Board Test status = Fail" | tee -a "/usr/local/bin/Testscripts/Testresult/$filename")

fi 


for i in $(ls /usr/local/bin/Testscripts/Testresult/Pass)
do 
	rm /usr/local/bin/Testscripts/Testresult/Pass/$i
done

for i in $(ls /usr/local/bin/Testscripts/Testresult/Fail)
do 
	rm /usr/local/bin/Testscripts/Testresult/Fail/$i
done

#device_path="/tmp/sysinfo/board_name"
#model_path="/tmp/sysinfo/model"
wifi_enable_disable=$(cat "$outputfilepath" | grep "wifi_enable_disable" | cut -d "=" -f 2 | tr -d '"')

#board_name=$(cat /tmp/sysinfo/board_name)

board_name=$(uci get boardconfig.board.model)
device_model=$(uci get boardconfig.board.model)

#if [ "$wifi_enable_disable" = "0" ];then
	#if echo "$board_name" | grep -qE "(Silbo_IAB|IAC)";then
		#board_name=$(echo "$board_name" | sed 's/./0/10')
	#fi
	#if echo "$board_name" | grep -qE "(Silbo_IA44)";then
	   #board_name=$(echo "$board_name" | sed 's/./0/9')
	#fi
#fi

#if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
 	  #board_name="$board_name"
#else
	#board_name="$board_name"
#fi

#device_model=$(cat /tmp/sysinfo/model)


#if [ "$wifi_enable_disable" = "0" ]; then
	#if echo "$device_model" | grep -qE "(Silbo_IAB|IAC)";then
		#device_model=$(echo "$model_path" | sed 's/./0/10')
	#fi
	#if echo "$device_model" | grep -qE "(Silbo_IA44)";then
	   #device_model=$(echo "$device_model" | sed 's/./0/9')
	#fi
#fi


#if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	#device_model="$device_model"
#else
	#device_model="$device_model"
#fi

if echo "$board_name" | grep -q "_GW"; then
	devicetype="Gateway"
else
	devicetype="Router"
fi


lan_mac_address=$(cat "$file" | grep "The lan mac addr is" | cut -d "-" -f 2 | tr -d ' ')

if [ "$wan_mac" = "y" ]; then
	wan_mac_address=$(cat "$file" | grep "The wan mac addr is" | cut -d "-" -f 2 | tr -d ' ')
else
	wan_mac_address="$test_status"
fi

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_mac_address=$(cat "$file" | grep "The wifi mac addr is" | cut -d "-" -f 2 | tr -d ' ')
else
	wifi_mac_address="$test_status1"
fi

imei_no=$(cat "$file" | grep "The IMEI number is" | cut -d "-" -f 2 | tr -d ' ')

modemname=$(cat "$file" | grep "Modem name" | cut -d "=" -f 2 | tr -d ' ')

modemmodel=$(cat "$file" | grep "Modem =" | cut -d "=" -f 2 | tr -d ' ')

#firmware_version=$(cat "$file" | grep "Modem firmware version" | cut -d "=" -f 2 | tr -d ' ')
firmware_version=$(grep "Modem firmware version" "$file" | awk -F ': ' '{print $2}' | tr -d ' ')

qccid1=$(cat "$file" | grep "QCCID for sim1" | cut -d "=" -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')
if [ "$DualSim" = "y" ]; then

qccid2=$(cat "$file" | grep "QCCID for sim2" | cut -d "=" -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')
else
qccid2="$test_status"
fi
#qccid2=$(grep "qccid2=" "$outputfilepath" | cut -d '=' -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')

modem_test=$(cat "$file" | grep "Modem test" | cut -d "=" -f 2 | tr -d ' ')
sim_strength_test=$(cat "$file" | grep "Sim1 signal strength test" | cut -d "=" -f 2 | tr -d ' ')

sim1_strength=$(cat "$file" | grep "Sim1 signal strength" | cut -d "=" -f 2 | tr -d ' ' | head -1)

ping_test1=$(cat "$file" | grep "Ethernet 1 Ping Test" | cut -d "=" -f 2 | tr -d ' ')


if [ "$ethernet1" = "y" ] && [ "$ethernet2" = "y" ]; then
	wan_test=$(cat "$file" | grep "WAN port Ping Test" | cut -d "=" -f 2 | tr -d ' ')
else
	wan_test="$test_status"
fi

if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then
	ping_test2=$(cat "$file" | grep "Ethernet 2 Ping Test" | cut -d "=" -f 2 | tr -d ' ')
else
	ping_test2="$test_status"
fi

if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then
	ping_test3=$(cat "$file" | grep "Ethernet 3 Ping Test" | cut -d "=" -f 2 | tr -d ' ')
else
	ping_test3="$test_status"
fi

if [ "$ethernet1" = "y" ] && [ "$ethernet3" = "y" ] && [ "$ethernet4" = "y" ] && [ "$ethernet5" = "y" ]; then
	ping_test4=$(cat "$file" | grep "Ethernet 4 Ping Test" | cut -d "=" -f 2 | tr -d ' ')
else
	ping_test4="$test_status"
fi
modem_test=$(cat "$file" | grep "Modem Ping Test" | cut -d "=" -f 2 | tr -d ' ')

gpio_test=$(cat "$file" | grep "Sim switching through gpio test" | cut -d "=" -f 2 | tr -d ' ')

if [ "$rtc_test" = "y" ]; then
	rtc_test_status=$(cat "$file" | grep "RTC test" | cut -d "=" -f 2 | tr -d ' ')
	#rtc_value=$(cat "$outputfilepath" 2>/dev/null | grep "rtc_value" | cut -d "=" -f 2)
	rtc_value=$(cat "$outputfilepath" | grep "rtc_value" | cut -d "=" -f 2 | tr -d '"')

	#rtc_value=$(grep "rtc_time" "$outputfilepath" | cut -d "=" -f 2 | tr -d '"' | tr -d '[:space:]')

	
else
	rtc_test_status="$test_status"
	rtc_value="$test_status"
fi

if [ "$switch_test" = "y" ]; then
	switch_test=$(cat "$file" | grep "Reset Switch Test" | cut -d "=" -f 2 | tr -d ' ')
else
	switch_test="$test_status"
fi

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_test=$(grep -o 'WIFI Test = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength=$(grep -o 'Wifi signal strength = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength_with_unit="$wifi_signal_strength dBm"
else
	wifi_test="$test_status1"
	wifi_signal_strength_with_unit="$test_status1"
fi

led_test=$(cat "$file" | grep "LED test" | cut -d "=" -f 2 | tr -d ' ')

AT_test=$(cat "$file" | grep "AT commands" | cut -d "=" -f 2 | tr -d ' ')

if [ "$rs485_test" = "y" ]; then
	rs485=$(cat "$file" | grep "RS485 test" | cut -d "=" -f 2 | tr -d ' ')
else
	rs485="$test_status"
fi

if [ "$rs232_test" = "y" ]; then
	rs232=$(cat "$file" | grep "RS232 test" | cut -d "=" -f 2 | tr -d ' ')
else
	rs232="$test_status"
fi

if [ "$di_test" = "y" ]; then
	digital_input=$(cat "$file" | grep "DigitalInput test" | cut -d "=" -f 2 | tr -d ' ')
else
	digital_input="$test_status"
fi

if [ "$do_test" = "y" ]; then
	digital_output=$(cat "$file" | grep "DigitalOutput test" | cut -d "=" -f 2 | tr -d ' ')
else
	digital_output="$test_status"
fi
if [ "$ai_test" = "y" ]; then
	calibration_test=$(cat "$file" | grep "Calibration Test" | cut -d "=" -f 2 | tr -d ' ')
	CurDevResistance_1=$(cat "$calibresfile" | grep "CurDevResistance_1" | cut -d "=" -f 2 | tr -d ' ')
	CurDevResistance_2=$(cat "$calibresfile" | grep "CurDevResistance_2" | cut -d "=" -f 2 | tr -d ' ')
	CurDevResistance_3=$(cat "$calibresfile" | grep "CurDevResistance_3" | cut -d "=" -f 2 | tr -d ' ')
	CurDevResistance_4=$(cat "$calibresfile" | grep "CurDevResistance_4" | cut -d "=" -f 2 | tr -d ' ')
else
	calibration_test="$test_status"
	CurDevResistance_1="$test_status"
	CurDevResistance_2="$test_status"
	CurDevResistance_3="$test_status"
	CurDevResistance_4="$test_status"
fi

if [ "$ai_test" = "y" ]; then
        
	analog_input=$(cat "$file" | grep "AnalogInput test" | cut -d "=" -f 2 | tr -d ' ')
	AI1=$(cat "$aifile" | grep "AI1" | cut -d "=" -f 2 | tr -d ' ')
	AI2=$(cat "$aifile" | grep "AI2" | cut -d "=" -f 2 | tr -d ' ')
	AI3=$(cat "$aifile" | grep "AI3" | cut -d "=" -f 2 | tr -d ' ')
	AI4=$(cat "$aifile" | grep "AI4" | cut -d "=" -f 2 | tr -d ' ')
	
else
	analog_input="$test_status"
    AI1="$test_status"
	AI2="$test_status"
	AI3="$test_status"
	AI4="$test_status"
fi
if [ "$usb_test" = "y" ]; then
	usb_test=$(awk -F'= *' '/USB test/ {print $2}' "$file" | tr -d ' ')
else
	usb_test="$test_status"
fi
if [ "$emmc_test" = "y" ]; then
	emmc_test_status=$(cat "$file" | grep "eMMC Card test" | cut -d "=" -f 2 | tr -d ' ')
else
	emmc_test_status="$test_status1"
fi
if [ "$nms_test" = "y" ]; then
	nms_test_status=$(cat "$file" | grep "NMS Registration Test" | cut -d "=" -f 2 | tr -d ' ')
	nms_ip=$(grep "tunip=" "$outputfile2path" | awk -F= '{print $2}')
	nms_url=$(grep "nms_url=" "$outputfile2path" | awk -F= '{print $2}')
else
	nms_test_status="$test_status1"
	nms_ip="$test_status1"
	nms_url="$test_status1"
fi


board_test=$(cat "$file" | grep "Board Test status" | cut -d "=" -f 2 | tr -d ' ')


rm -f /root/.ssh/known_hosts


if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ] && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ] && [ "$res16" = "y" ] && [ "$res17" = "y" ] && [ "$res18" = "y" ] && [ "$res19" = "y" ] && [ "$res20" = "y" ] && [ "$res21" = "y" ] && [ "$res22" = "y" ] && [ "$res23" = "y" ] && [ "$res24" = "y" ] && [ "$res25" = "y" ] && [ "$res26" = "y" ] && [ "$res27" = "y" ] && [ "$res28" = "y" ] && [ "$res29" = "y" ] && [ "$res30" = "y" ] && [ "$res31" = "y" ] && [ "$res32" = "y" ] && [ "$res33" = "y" ] && [ "$res34" = "y" ] && [ "$res35" = "y" ] && [ "$res36" = "y" ] && [ "$res37" = "y" ];  then
	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Pass/$filename	
	status=1	
else
	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Fail/$filename	
	status=2
fi 

sleep 2
echo "SENDING DATA TO SERVER.........."


data=$(cat <<EOF
{
  "device_id": "$serial_number",
  "device_type": "$devicetype",
  "device_model": "$device_model",
  "testing_time": "$time_stamp",
  "board_test_status":"$board_test",
  "customer_name":"$customer_name",
  "tester_name":"$tester_name1",
  "json_data": {
    "device_id":"$serial_number",
    "device_type":"$devicetype",
    "device_model":"$device_model",
    "testing_time":"$time_stamp",
    "board_test_status":"$board_test",
    "board_name":"$board_name",
    "wan_mac":"$wan_mac_address",
    "lan_mac":"$lan_mac_address",
    "wifi_mac":"$wifi_mac_address",
    "at_commands_test_result":"$AT_test",
    "imei_number_for_modem_1":"$imei_no",
    "modem_name":"$modemname",
    "modem_model":"$modemmodel",
    "modem_firmware_version":"$firmware_version",
    "modem_ping_status":"$modem_test",
    "qccid_for_sim1":"$qccid1",
    "qccid_for_sim2":"$qccid2",
    "sim1_signal_strength":"$sim1_strength", 
    "sim1_signal_strength_test_result":"$sim_strength_test",
    "lan1_ping_status":"$ping_test1",
    "lan2_ping_status":"$ping_test2",
    "lan3_ping_status":"$ping_test3",
    "lan4_ping_status":"$ping_test4",
    "wan_ping status":"$wan_test",     
    "rtc_test_status":"$rtc_test_status",
    "rtc_value":"$rtc_value",
    "reset_switch_test_status":"$switch_test",
    "wifi_test_status":"$wifi_test",
    "wifi_signal_strength":"$wifi_signal_strength_with_unit",
    "led_test_status":"$led_test",
    "rs485_test_status":"$rs485",
    "rs232_test_status":"$rs232",
    "digital_out_test_status":"$digital_output",
    "digital_in_test_status":"$digital_input",
    "calibration_test_status":"$calibration_test",
    "CurDevResistance1":"$CurDevResistance_1",
    "CurDevResistance2":"$CurDevResistance_2",
    "CurDevResistance3":"$CurDevResistance_3",
    "CurDevResistance4":"$CurDevResistance_4",
    "AI_1_Value":"$AI1",
    "AI_2_Value":"$AI2",
    "AI_3_Value":"$AI3",
    "AI_4_Value":"$AI4",
    "analog_input_test":"$analog_input",
    "usb_test_status":"$usb_test",
    "emmc_card_test_status":"$emmc_test_status",
    "nms_test_status":"$nms_test_status",
    "nms_url":"$nms_url",
    "device_vpn_ip":"$nms_ip",
    "reboot_status":"$result",
    "tester_name":"$tester_name1",
    "record_type":"1"
  }
}
EOF
)
echo "$data"
max_attempts=5
attempts=0

while [ $attempts -lt $max_attempts ]; do
    if ping -c 1 -W 2 "productionapp.silbo.co.in" &> /dev/null; then
        echo "Server is reachable. Sending data..."
		curl --header "Content-Type: application/json" --data "$data" -k -v http://productionapp.silbo.co.in/api/save_data/
        break  # exit the loop once data is sent
    else
        echo "Server is not reachable. Retrying in 10 seconds (attempt $((attempts + 1)) of $max_attempts)..."
        sleep 10
        attempts=$((attempts+1))
    fi
done

if [ $attempts -eq $max_attempts ]; then
    echo "Failed to send data after $max_attempts attempts. Exiting with an error."
fi

sleep 3

echo " "
echo "=====================================================================================
			        DISPLAYING REPORT 
===================================================================================== "

if [ "$status" = 1 ];then
	cat /usr/local/bin/Testscripts/Testresult/Pass/$filename
	
echo -e "\e[32m ==============================================
 ____   _    ____ ____  
|  _ \ / \  / ___/ ___| 
| |_) / _ \ \___ \___ \ 
|  __/ ___ \ ___) |__) |
|_| /_/   \_\____/____/ 
                        
==============================================\e[0m"
else
	cat /usr/local/bin/Testscripts/Testresult/Fail/$filename
	
echo -e "\e[31m==============================================
 ____	 _____ _       
|  ___/ \  |_ _| |    
| |_ / _ \  | || |    
|  _/ ___ \ | || |___ 
|_|/_/   \_\___|_____|

==============================================\e[0m"
fi

