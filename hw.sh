#!/bin/bash
#rm hw.txt
if [ "$EUID" -ne 0 ]
  then echo "Please run as sudo"
  exit
fi
read -p "Enter your brandeis ID: " s1
echo "CPU:" >> ${s1}hw.txt
lscpu | grep -o "Model name.*" >> ${s1}hw.txt
lscpu | sed -n "s/^.*Core.*\([0-9]\{1,3\}\)$/Core:\1/p" >> ${s1}hw.txt
lscpu | sed -n "s/^CPU(s).*\([0-9]\{1,3\}\)$/Thread:\1/p" >> ${s1}hw.txt
free -h | sed -n "s/Mem:[^0-9]*\([0-9]\{1,4\}\).*/Memory:\1GB/p" >> ${s1}hw.txt #grep -o "Mem:.[^G]*" >> hw.txt
echo "Monitors:" >> ${s1}hw.txt
grep "(DFP-" /var/log/Xorg.0.log | head -17 | cut -d\: -f2 | sort -u >> hw.txt
#xrandr | sed -n "s/\(.*\) connected \(.*\)+.*+0[^0-9]*\([0-9]\{0,3\}mm.*mm\)/Port:\1 Resolution:\2 Size: \3/p " #>> ${s1}hw.txt
#xrandr | sed -n "s/ *\([^ ]*\) \{1,\}\([^ ]*\)\*+/Resolution and refresh:\1 \2/p" >> ${s1}hw.txt
moni=$(xrandr | sed -n "N;s/\(.*\) connected \(.*\)+.*+0[^0-9]*\([0-9]\{0,3\}mm.*mm\).*\n *\([^ ]*\) \{1,\}\([^ ]*\)\*+.*/Port:\1 Resolution:\2@\5 Size:\3/p;D")
echo ${moni[1]}
#sed -n "s/(DFP-//p" -i hw.txt
cat hw.txt | column -t >> ${s1}hw.txt
rm hw.txt
exit
echo "GPUs:" >> ${s1}hw.txt
lspci | sed -n 's/^.*VGA compatible controller.*\[\(.*\)\].*$/\1/p' >> ${s1}hw.txt
echo "Drives:" >> ${s1}hw.txt
lsblk -o "MODEL","SIZE","TYPE","ROTA" | sed -n "s/ 1/HDD/; s/ 0/SSD/; /USB/!s/ *\([^ ]*\) *\([^ ]*\) disk \([^ ]*\)/Model:\1 Size:\2 Type:\3/p" >> hw.txt
drives=$(lsblk -o "Model","Size" | grep USB)
IFS=$'\n'
for line in $drives
do
	echo "Is this drive owned by the Hagan Group? Select the corresponding number:"
	echo $line
	select yn in "Group Owned" "User Owned" 
	do
		case $yn in
			"Group Owned" ) lsblk -o "MODEL","SIZE","TYPE","ROTA" | sed -n "s/ 1/HDD/; s/ 0/SSD/; /$line/s/ *\([^ ]*\) *\([^ ]*\) disk \([^ ]*\)/Model:\1 Size:\2 Type:\3/p" >> hw.txt
				break;;
			"User Owned" ) break;;
		esac
	done
done
cat hw.txt | column -t >> ${s1}hw.txt
echo "Motherboard/System:" >> ${s1}hw.txt
#cat /sys/devices/virtual/dmi/id/board_{vendor,name,version} >>hw.txt
dmesg | sed -n "s/.*DMI: \(.*\)/\1/p" >> ${s1}hw.txt
echo "Connectivity:" >> ${s1}hw.txt
ip route | sed -n "s/default.*src \([^ ]*\).*/IPv4 Address:\1/p" >> ${s1}hw.txt
lspci | sed -n s"/.*Ethernet controller: \(.*\) (.*/\1/p" >> ${s1}hw.txt
echo "Software:" >> ${s1}hw.txt
sed -n "s/^PRETTY_NAME="'"\(.*\)"'"$/\1/p" /etc/os-release >> ${s1}hw.txt
(echo "Kernel:";uname -r) |tr '\n' '\t' >> ${s1}hw.txt
echo "" >> ${s1}hw.txt
(echo "Serial/Service Tag:"; cat /sys/class/dmi/id/product_serial) | tr '\n' '\t' >> ${s1}hw.txt
rm hw.txt

#TODO: Fix monitor formatting
