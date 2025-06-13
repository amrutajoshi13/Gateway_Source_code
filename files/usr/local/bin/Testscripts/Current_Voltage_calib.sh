
#!/bin/bash

echo " "
echo "====================================================================================="
echo "                               CALIBRATION TEST "
echo "====================================================================================="
CONFIG_FILE="/root/ADCUtilityComponent/etc/Config/ADCUtilityConfig.cfg"
#WEB_CONFIG_FILE="/root/ReadAIAppComponent/etc/Config/ReadAIAppConfig.cfg"
. /usr/local/bin/Testscripts/testscriptconfig.cfg
> /usr/local/bin/Testscripts/calibout.txt
> /usr/local/bin/Testscripts/calibres.txt

NoOfChannels=$(uci get analoginputconfig.analoginputconfig.NoOfInputs)
	
ChannelType1=$(uci get analoginputconfig.analoginputconfig.ChannelType1)
ChannelType2=$(uci get analoginputconfig.analoginputconfig.ChannelType2)
ChannelType3=$(uci get analoginputconfig.analoginputconfig.ChannelType3)
ChannelType4=$(uci get analoginputconfig.analoginputconfig.ChannelType4)
for i in $(seq 1 $NoOfChannels); do
    ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType$i)
    echo "ChannelType $i=$ChannelType"
done 



StoreResistances() 
{
	
	
	

    if [[ $ChannelType1 -eq 1 ]]; then
		if [ -z "$CurDevResistance_1" ]; then
			CurDevResistance_1=$defCurDevResistance
			CurDevResistance_1=$(echo "$CurDevResistance_1 * 10000000000000" | bc)
		else
		   CurDevResistance_1=$(echo "$CurDevResistance_1 * 10000000000000" | bc)
		fi
     elif [[ $ChannelType1 -eq 2 ]]; then
		if [ -z "$VolMultiplier_1" ]; then
			VolMultiplier_1=$defVolMultiplier
			VolMultiplier_1=$(echo "$VolMultiplier_1 * 100000000000000000" | bc)
		else
		   VolMultiplier_1=$(echo "$VolMultiplier_1 * 100000000000000000" | bc)
		fi
    fi 
		
    if [[ $ChannelType1 -eq 1 ]]; then
		if [ -z "$CurDevResistance_2" ]; then
			CurDevResistance_2=$defCurDevResistance
			CurDevResistance_2=$(echo "$CurDevResistance_2 * 10000000000000" | bc)    
		else
			CurDevResistance_2=$(echo "$CurDevResistance_2 * 10000000000000" | bc)
		fi
	elif [[ $ChannelType2 -eq 2 ]]; then
		if [ -z "$VolMultiplier_2" ]; then
			VolMultiplier_2=$defVolMultiplier
			VolMultiplier_2=$(echo "$VolMultiplier_2 * 100000000000000000" | bc)
		else
		   VolMultiplier_2=$(echo "$VolMultiplier_2 * 100000000000000000" | bc)
		fi
    fi 
    
    if [[ $ChannelType1 -eq 1 ]]; then
		if [ -z "$CurDevResistance_3" ]; then
			CurDevResistance_3=$defCurDevResistance
			CurDevResistance_3=$(echo "$CurDevResistance_3 * 10000000000000" | bc)   
		else
			CurDevResistance_3=$(echo "$CurDevResistance_3 * 10000000000000" | bc)
		fi
	elif [[ $ChannelType3 -eq 2 ]]; then
		if [ -z "$VolMultiplier_3" ]; then
			VolMultiplier_3=$defVolMultiplier
			VolMultiplier_3=$(echo "$VolMultiplier_3 * 100000000000000000" | bc)
		else
		   VolMultiplier_3=$(echo "$VolMultiplier_3 * 100000000000000000" | bc)
		fi
    fi 
    
    if [[ $ChannelType1 -eq 1 ]]; then
		if [ -z "$CurDevResistance_4" ]; then
			CurDevResistance_4=$defCurDevResistance
			CurDevResistance_4=$(echo "$CurDevResistance_4 * 10000000000000" | bc)    
		else
			CurDevResistance_4=$(echo "$CurDevResistance_4 * 10000000000000" | bc)
		fi
	elif [[ $ChannelType4 -eq 2 ]]; then
		if [ -z "$VolMultiplier_4" ]; then
			VolMultiplier_4=$defVolMultiplier
			VolMultiplier_4=$(echo "$VolMultiplier_4 * 100000000000000000" | bc)
		else
		   VolMultiplier_4=$(echo "$VolMultiplier_4 * 100000000000000000" | bc)
		fi
    fi 

 if [[ $ChannelType1 -eq 1 ]]; then	
		CurDevResistance1=$CurDevResistance_1
		local var1=${CurDevResistance1:0:2}
		local var2=${CurDevResistance1:2:2}
		local var3=${CurDevResistance1:4:2}
		local var4=${CurDevResistance1:6:2}
		local var5=${CurDevResistance1:8:2}
		local var6=${CurDevResistance1:10:2}
		local var7=${CurDevResistance1:12:2}
		local var8=${CurDevResistance1:14:2}
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x200))
	elif [[ $ChannelType1 -eq 2 ]]; then
		VolMultiplier1=$VolMultiplier_1
		offset1=$offset_1
		local var1=${VolMultiplier1:0:2}
		local var2=${VolMultiplier1:2:2}
		local var3=${VolMultiplier1:4:2}
		local var4=${VolMultiplier1:6:2}
		local var5=${VolMultiplier1:8:2}
		local var6=${VolMultiplier1:10:2}
		local var7=${VolMultiplier1:12:2}
		local var8=${VolMultiplier1:14:2}
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x200))
		local var2=${offset1:2:2}
		local var3=${offset1:4:2}
		printf "\x$var2\x$var3" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x240))	
		#printf "$offset_1" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x240))	

	
	
	fi	
	
	if [[ $ChannelType2 -eq 1 ]]; then	
		CurDevResistance2=$CurDevResistance_2
		local var1=${CurDevResistance2:0:2}
		local var2=${CurDevResistance2:2:2}
		local var3=${CurDevResistance2:4:2}
		local var4=${CurDevResistance2:6:2}
		local var5=${CurDevResistance2:8:2}
		local var6=${CurDevResistance2:10:2}
		local var7=${CurDevResistance2:12:2}
		local var8=${CurDevResistance2:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x210))
	elif [[ $ChannelType2 -eq 2 ]]; then
		VolMultiplier2=$VolMultiplier_2
		offset2=$offset_2		
		local var1=${VolMultiplier2:0:2}
		local var2=${VolMultiplier2:2:2}
		local var3=${VolMultiplier2:4:2}
		local var4=${VolMultiplier2:6:2}
		local var5=${VolMultiplier2:8:2}
		local var6=${VolMultiplier2:10:2}
		local var7=${VolMultiplier2:12:2}
		local var8=${VolMultiplier2:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x210))
		local var2=${offset2:2:2}
		local var3=${offset2:4:2}
		printf "\x$var2\x$var3" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x250))		
	fi
	
	if [[ $ChannelType3 -eq 1 ]]; then	
		CurDevResistance3=$CurDevResistance_3
		local var1=${CurDevResistance3:0:2}
		local var2=${CurDevResistance3:2:2}
		local var3=${CurDevResistance3:4:2}
		local var4=${CurDevResistance3:6:2}
		local var5=${CurDevResistance3:8:2}
		local var6=${CurDevResistance3:10:2}
		local var7=${CurDevResistance3:12:2}
		local var8=${CurDevResistance3:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x220))
	elif [[ $ChannelType3 -eq 2 ]]; then
		VolMultiplier3=$VolMultiplier_3
		offset3=$offset_3				
		local var1=${VolMultiplier3:0:2}
		local var2=${VolMultiplier3:2:2}
		local var3=${VolMultiplier3:4:2}
		local var4=${VolMultiplier3:6:2}
		local var5=${VolMultiplier3:8:2}
		local var6=${VolMultiplier3:10:2}
		local var7=${VolMultiplier3:12:2}
		local var8=${VolMultiplier3:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x220))
		local var2=${offset3:2:2}
		local var3=${offset3:4:2}
		printf "\x$var2\x$var3" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x260))		
	fi
	if [[ $ChannelType4 -eq 1 ]]; then	
		CurDevResistance4=$CurDevResistance_4
		local var1=${CurDevResistance4:0:2}
		local var2=${CurDevResistance4:2:2}
		local var3=${CurDevResistance4:4:2}
		local var4=${CurDevResistance4:6:2}
		local var5=${CurDevResistance4:8:2}
		local var6=${CurDevResistance4:10:2}
		local var7=${CurDevResistance4:12:2}
		local var8=${CurDevResistance4:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x230))
	elif [[ $ChannelType4 -eq 2 ]]; then
		VolMultiplier4=$VolMultiplier_4
		offset4=$offset_4				
		local var1=${VolMultiplier4:0:2}
		local var2=${VolMultiplier4:2:2}
		local var3=${VolMultiplier4:4:2}
		local var4=${VolMultiplier4:6:2}
		local var5=${VolMultiplier4:8:2}
		local var6=${VolMultiplier4:10:2}
		local var7=${VolMultiplier4:12:2}
		local var8=${VolMultiplier4:14:2}		
		printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x230))
		local var2=${offset4:2:2}
		local var3=${offset4:4:2}
		printf "\x$var2\x$var3" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x270))		
	
	fi
	
}
	

for ChannelNumber in $(seq 1 $NoOfChannels); do
    ChannelTypeVar="ChannelType$ChannelNumber"
    ChannelType=$(uci get analoginputconfig.analoginputconfig.$ChannelTypeVar)
					
		echo -e "\e[38;5;214mPlease Disconnect the Source for ChannelNumber$ChannelNumber\e[0m"
		sleep 10
		
		
    if [[ $ChannelType -eq 1 ]]; then
    	echo -e "\e[38;5;214mChannel Type is 1, proceeding with calibration.\e[0m"

				Voltage_value_read_without_source=$(/root/ADCUtilityComponent/ADCUtility $ChannelNumber 2 | grep "The Average of samples" | awk '{print $5}')
				echo "Voltage_value_read_without_source=$Voltage_value_read_without_source"
				sed -i "/^Voltage_value_read_without_source_$ChannelNumber/d" "$CONFIG_FILE"
				echo "Voltage_value_read_without_source_$ChannelNumber=$Voltage_value_read_without_source" >> /tmp/Voltagevalues.txt
	
				# Calibration Test With Source.
				echo -e "\e[38;5;214mPlease Connect the Source for ChannelNumber$ChannelNumber\e[0m"
				sleep 10

				Voltage_value_read_with_Source=$(/root/ADCUtilityComponent/ADCUtility $ChannelNumber 2 | grep "The Average of samples" | awk '{print $5}')
				if [ -z "$Voltage_value_read_with_Source" ]; then
					Voltage_value_read_with_Source=0
				fi
				echo "Voltage_value_read_with_Source=$Voltage_value_read_with_Source"

				# Calculate the resistor value
				if [[ ! -z "$Voltage_value_read_with_Source" ]]; then
					Current_source_value=$Current_source_value
					CurDevResistance=$(echo "scale=10; $Voltage_value_read_with_Source * 1000 / $Current_source_value" | bc)
					if [[ $(echo "$CurDevResistance == 0" | bc) -eq 1 ]]; then
						CurDevResistance=$defCurDevResistance
					fi				
					echo "CurDevResistance=$CurDevResistance"
					sed -i "/^CurDevResistance_$ChannelNumber/d" /usr/local/bin/Testscripts/current_resistance.txt
					echo "CurDevResistance_$ChannelNumber=$CurDevResistance" >> /usr/local/bin/Testscripts/current_resistance.txt
					sed -i "/^CurDevResistance_$ChannelNumber/d" "$CONFIG_FILE"
					#sed -i "/^AInput$ChannelNumberCurDevResistance/d" "$WEB_CONFIG_FILE"
					# Append the updated resistance value to the configuration file
					uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_$ChannelNumber=$CurDevResistance
					uci commit ADCUtilityConfigGeneric
					echo "CurDevResistance_$ChannelNumber=$CurDevResistance" >> "$CONFIG_FILE"		
					#echo "AInput$ChannelNumberCurDevResistance=$CurDevResistance" >> "$WEB_CONFIG_FILE"		
				    is_within_range=$(echo "$CurDevResistance >= $minCurDevResistance && $CurDevResistance <= $maxCurDevResistance" | bc -l)	
				fi
			
			
			  elif [[ $ChannelType -eq 2 ]]; then
				Voltage_value_read_without_source=$(sh /bin/AIOutility.sh $ChannelNumber 2 | awk '/Voltage/ {print $2}')
				offset=$(/root/ADCUtilityComponent/ADCUtility $ChannelNumber 2 | grep "ConversionValue" | awk '{print $12}')		
				echo "Voltage_value_read_without_source=$Voltage_value_read_without_source"
				echo "Voltage_value_read_without_source_$ChannelNumber=$Voltage_value_read_without_source" >> /tmp/Voltagevalues.txt
				offset=$(echo $offset|awk '{print $1}')
				
					sed -i "/^offset_$ChannelNumber/d" "$CONFIG_FILE"
					sed -i "/^offset_$ChannelNumber/d" /usr/local/bin/Testscripts/current_resistance.txt
					offset_$ChannelNumber=$offset
					if [ "$offset=0xff" ] || [ "$offset=0xFF" ];then
					echo "offset_$ChannelNumber=0x02" >> /tmp/offset.txt
					fi
					echo "offset_$ChannelNumber=$offset"  >> "$CONFIG_FILE"
					echo "offset_$ChannelNumber=$offset" >> /usr/local/bin/Testscripts/current_resistance.txt
					uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_$ChannelNumber=$offset
					uci commit ADCUtilityConfigGeneric
		
			# Voltage Calibration Test With Source.
			echo -e "\e[38;5;214mPlease Connect the Source for ChannelNumber$ChannelNumber\e[0m"
			sleep 10

					Voltage_value_read_with_Source=$(/root/ADCUtilityComponent/ADCUtility $ChannelNumber 2 | grep "The Average of samples" | awk '{print $5}')	
					if [[ -z "$Voltage_value_read_with_Source" ]]; then
						VolMultiplier=$defVolMultiplier
					fi	
				if [[ ! -z "$Voltage_value_read_with_Source" ]]; then
					Voltage_source_value=$Voltage_source_value
					multifactor=$(echo "scale=10; $Voltage_source_value / $Voltage_value_read_with_Source" | bc)
					echo "multifactor=$multifactor"
					divisionfactor=$(echo "scale=10; 1 / $multifactor" | bc)
					VolMultiplier=$divisionfactor
					sed -i "/^VolMultiplier_$ChannelNumber/d" "$CONFIG_FILE"
					if [[ -z "$VolMultiplier" ]]; then
						VolMultiplier=$defVolMultiplier
					fi	
					sed -i "/^VolMultiplier_$ChannelNumber/d" /usr/local/bin/Testscripts/current_resistance.txt
					echo "VolMultiplier_$ChannelNumber=$VolMultiplier" >> /usr/local/bin/Testscripts/current_resistance.txt
					echo "VolMultiplier_$ChannelNumber=$VolMultiplier" >> "$CONFIG_FILE"
					
					
					uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_$ChannelNumber=$VolMultiplier
					uci commit ADCUtilityConfigGeneric
				    is_within_range=$(echo "$VolMultiplier >= $minVolMultiplier && $VolMultiplier <= $maxVolMultiplier" | bc -l)
				
				fi
				
			fi	
			
		time_stamp=$(date)


		if [[ "$is_within_range" -eq 1 ]]; then
			echo -e "\e[1;32m [$time_stamp] Channel $ChannelNumber Calibration Successful = PASS \e[0m"
			sed -i "/Channel $ChannelNumber:/d" /usr/local/bin/Testscripts/calibres.txt
			echo "[$time_stamp] Channel $ChannelNumber: Calibration Successful = PASS" >> /usr/local/bin/Testscripts/calibres.txt
		else
			echo -e "\e[1;31m [$time_stamp] Channel $ChannelNumber Calibration Failed = FAIL \e[0m"
			sed -i "/Channel $ChannelNumber:/d" /usr/local/bin/Testscripts/calibout.txt
			echo "[$time_stamp] Channel $ChannelNumber: Calibration Failed = FAIL" >> /usr/local/bin/Testscripts/calibres.txt
		fi
done
		if grep -q "Calibration Failed = FAIL" /usr/local/bin/Testscripts/calibres.txt; then
			echo -e "Calibration Failed" >> /usr/local/bin/Testscripts/calibout.txt
		else
			echo -e "Calibration Successful" >> /usr/local/bin/Testscripts/calibout.txt
		fi
		
		
		cp /etc/config/ADCUtilityConfigGeneric /root/InterfaceManager/config/
		cp /etc/config/ADCUtilityConfigGeneric /Web_Page_Gateway_Apps/Default_Gateway/config/


. /usr/local/bin/Testscripts/current_resistance.txt

StoreResistances

sh /root/usrRPC/script/Board_Recycle_12V_Script.sh
