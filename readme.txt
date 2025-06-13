Commands to comment debug console 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
link : https://openwrt.org/docs/guide-user/hardware/terminate.console.on.serial

If needing to utilize the terminal for RAW data/Modem data, reconfigure /dev/tty via the coreutils-stty module.

Add kernel.printk = 0 4 1 7 to /etc/sysctl.d/:
 echo "kernel.printk = 0 4 1 7" > /etc/sysctl.d/10-printk.conf
Edit /etc/inittab:
Comment out lines starting with ttyS0:*, ttyATH0:* and ::askconsole:*
sed -i -r -e "s/^((ttyS0|ttyATH0|::askconsole):.*)/#\0/" /etc/inittab
Reboot
