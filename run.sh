#!/bin/bash
isinstalled=true
ipaddress=''
ifconfig_bin='ifconfig'
oray_vpn_address=''
isinstalledcentos()
{
if [ -a "/etc/init.d/runsunloginclient" ]; then
	echo "Installed"
else
	isinstalled=false
fi
}

isinstalledubuntu()
{
if [ -a "/etc/init/runsunloginclient.conf" ]; then
	echo "Installed"
else
	isinstalled=false
fi
}

isinstalledubuntu_hv()
{
if [ -a "/etc/systemd/system/runsunloginclient.service" ]; then
	echo "Installed"
else
	isinstalled=false
fi
}

isinstalledcentos_hv()
{
if [ -a "/etc/systemd/system/runsunloginclient.service" ]; then
	echo "Installed"
else
	isinstalled=false
fi
}

printhowtouse()
{
	echo "Run it with no argument to start Sunloginclient"
	echo "Run it with [help] as it argument to print the help information"
	#echo "Run it with [start] as it argument to start Sunloginclient"
	echo "Run it with [stop] as it argument to stop Sunloginclient"
}

#change directory to script path
curpath=$(cd "$(dirname "$0")"; pwd)
cd $curpath > /dev/null

source ./scripts/common.sh
os_version_int=${os_version%.*}
for i in $(seq 1 10)
do
	os_version_int=${os_version_int%.*}
done


if [ $os_name == 'ubuntu' ]; then
	if [ $os_version_int -lt 15 ]; then
		isinstalledubuntu
	else
		isinstalledubuntu_hv
	fi
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	if [ $os_version_int -lt 7 ]; then
		ifconfig_bin='/sbin/ifconfig'
		isinstalledcentos
	else
		isinstalledcentos_hv
	fi

else
	echo 'unknown os'
	exit
fi

if [ $# -gt 0 ]; then
	if [ $1 == "stop" ]; then
		if [ $isinstalled == true ] ;then
			check_root "Installed Sunlogin client needs root to stop"
			cd ./scripts
			source stop.sh
			cd -
			exit
		else
			killallsunloginclient
			rm /var/tmp/linux_oray_sunloginclient_2.1.lock 1>/dev/null 2>&1
			exit
		fi
	elif [ $1 == "help" ]; then
		printhowtouse
		exit
	fi
fi
if [ $isinstalled == true ] ;then
	check_root "Installed Sunlogin client needs root to start"
	cd ./scripts
	source start.sh
	cd -
	exit

else
	killallsunloginclient
	cd ./bin/$os_bits/
	./sunloginclient_linux -g 1>/dev/null 2>&1  &
	sleep 3
	firefox 127.0.0.1:30080 1>/dev/null 2>&1  &
fi

