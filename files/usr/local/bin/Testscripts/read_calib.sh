#!bin/bash
 
. /usr/local/bin/Testscripts/current_resistance.txt

. /usr/local/bin/Testscripts/testscriptconfig.cfg

NoOfChannels=$(uci get analoginputconfig.analoginputconfig.NoOfInputs)
ChannelType1=$(uci get analoginputconfig.analoginputconfig.ChannelType1)
ChannelType2=$(uci get analoginputconfig.analoginputconfig.ChannelType2)
ChannelType3=$(uci get analoginputconfig.analoginputconfig.ChannelType3)
ChannelType4=$(uci get analoginputconfig.analoginputconfig.ChannelType4)



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

StoreResistances() 
{
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
 
 
ReadResistances() {
    # Read the stored resistance hex values from flash
    . /usr/local/bin/Testscripts/testscriptconfig.cfg

     for i in $(seq 1 $NoOfChannels); do
    ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType$i)
    echo "ChannelType $i=$ChannelType"
        	if [[ $ChannelType -eq 1 ]]; then
				echo "VolMultiplier_$i=$defVolMultiplier"
				echo "offset_$i=$defoffset"
				uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_$i=$defVolMultiplier
				uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_$i=$defoffset
			    uci commit ADCUtilityConfigGeneric 
			elif [[ $ChannelType -eq 2 ]]; then
				echo "CurDevResistance_4=$defCurDevResistance"
				uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_$i=$defCurDevResistance
				uci commit ADCUtilityConfigGeneric 
			fi
   done 
    
    	if [[ $ChannelType1 -eq 1 ]]; then	
			local res1_hex=$(hexdump -v -n 8 -s 0x200 -e '8/1 "%02X"' /tmp/factory.bin)
			CurDevResistance1=$(echo "scale=10; $res1_hex / 10000000000000" | bc)
			echo "CurDevResistance_1=$CurDevResistance1"
			uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_1=$CurDevResistance1
			uci commit ADCUtilityConfigGeneric
		elif [[ $ChannelType1 -eq 2 ]]; then
			local res1_hex=$(hexdump -v -n 8 -s 0x200 -e '8/1 "%02X"' /tmp/factory.bin)
			VolMultiplier1=$(echo "scale=10; $res1_hex / 100000000000000000" | bc)
			echo "VolMultiplier_1=$VolMultiplier1"
			
			local res5_hex=$(hexdump -v -n 2 -s 0x240 -e '2/1 "%02X"' /tmp/factory.bin)
			offset1="0x$res5_hex" 
			echo "offset_1=$offset1"  # This should now show the correct format
			uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_1=$VolMultiplier1
			uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_1=$offset1
			uci commit ADCUtilityConfigGeneric   
	   fi

    	if [[ $ChannelType2 -eq 1 ]]; then	
			 local res2_hex=$(hexdump -v -n 8 -s 0x210 -e '8/1 "%02X"' /tmp/factory.bin)
			CurDevResistance2=$(echo "scale=10; $res2_hex / 10000000000000" | bc)
			echo "CurDevResistance_2=$CurDevResistance2"
			uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_2=$CurDevResistance2
			uci commit ADCUtilityConfigGeneric   
		elif [[ $ChannelType2 -eq 2 ]]; then
			local res2_hex=$(hexdump -v -n 8 -s 0x210 -e '8/1 "%02X"' /tmp/factory.bin)
			VolMultiplier2=$(echo "scale=10; $res2_hex / 100000000000000000" | bc)
			echo "VolMultiplier_2=$VolMultiplier2"
			local res6_hex=$(hexdump -v -n 2 -s 0x250 -e '1/1 "%02X"' /tmp/factory.bin)
            offset2="0x$res6_hex" 
            
			uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_2=$offset2
			uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_2=$VolMultiplier2
			uci commit ADCUtilityConfigGeneric   
	   fi
    	if [[ $ChannelType3 -eq 1 ]]; then	
			 local res3_hex=$(hexdump -v -n 8 -s 0x220 -e '8/1 "%02X"' /tmp/factory.bin)
			 CurDevResistance3=$(echo "scale=10; $res3_hex / 10000000000000" | bc)
			 echo "CurDevResistance_3=$CurDevResistance3"
			 uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_3=$CurDevResistance3
			 uci commit ADCUtilityConfigGeneric     
		elif [[ $ChannelType3 -eq 2 ]]; then
			local res3_hex=$(hexdump -v -n 8 -s 0x220 -e '8/1 "%02X"' /tmp/factory.bin)
			VolMultiplier3=$(echo "scale=10; $res3_hex / 100000000000000000" | bc)
			echo "VolMultiplier_3=$VolMultiplier3"
			local res7_hex=$(hexdump -v -n 2 -s 0x260 -e '2/1 "%02X"' /tmp/factory.bin)
            offset3="0x$res7_hex" 
			uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_3=$offset3
			uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_3=$VolMultiplier3
			uci commit ADCUtilityConfigGeneric   
	   fi
    	if [[ $ChannelType4 -eq 1 ]]; then	
			local res4_hex=$(hexdump -v -n 8 -s 0x230 -e '8/1 "%02X"' /tmp/factory.bin)
			CurDevResistance4=$(echo "scale=10; $res4_hex / 10000000000000" | bc)
			echo "CurDevResistance_4=$CurDevResistance4"
			uci set ADCUtilityConfigGeneric.adcutilityconfig.CurDevResistance_4=$CurDevResistance4
			uci commit ADCUtilityConfigGeneric    
		elif [[ $ChannelType4 -eq 2 ]]; then
			local res4_hex=$(hexdump -v -n 8 -s 0x230 -e '8/1 "%02X"' /tmp/factory.bin)
			VolMultiplier4=$(echo "scale=10; $res4_hex / 100000000000000000" | bc)
			echo "VolMultiplier_4=$VolMultiplier4"
			local res8_hex=$(hexdump -v -n 2 -s 0x270 -e '2/1 "%02X"' /tmp/factory.bin)
            offset4="0x$res8_hex" 
			uci set ADCUtilityConfigGeneric.adcutilityconfig.offset_4=$offset4
			uci set ADCUtilityConfigGeneric.adcutilityconfig.VolMultiplier_4=$VolMultiplier4
			uci commit ADCUtilityConfigGeneric   
	   fi

}
 
StoreResistances
ReadResistances


