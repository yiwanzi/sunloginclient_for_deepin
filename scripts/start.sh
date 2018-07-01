#!/bin/bash
isinstalled=true
ipaddress=''
oray_vpn_address=''
isinstalledcentos()
{
if [ -a "/etc/init.d/runsunloginclient" ]; then
	echo "Installed"
else
	echo "Please run install.sh first"
	isinstalled=false
	exit
fi
}

isinstalledubuntu()
{
if [ -a "/etc/init/runsunloginclient.conf" ]; then
	echo "Installed"
else
	echo "Please run install.sh first"
	isinstalled=false
	exit
fi
}

isinstalledubuntu_hv()
{
if [ -a "/etc/systemd/system/runsunloginclient.service" ]; then
	echo "Installed"
else
	echo "Please run install.sh first"
	isinstalled=false
	exit
fi
}

isinstalledcentos_hv()
{
if [ -a "/etc/systemd/system/runsunloginclient.service" ]; then
	echo "Installed"
else
	echo "Please run install.sh first"
	isinstalled=false
	exit
fi
}

echo "Attempting to start sunlgin"
echo "-------------------------------"
#change directory to script path
curpath=$(cd "$(dirname "$0")"; pwd)
cd $curpath > /dev/null

source ./common.sh
os_version_int=${os_version%.*}
for i in $(seq 1 10)
do
	os_version_int=${os_version_int%.*}
done

#check root
check_root "Installed Sunlogin client needs root to start"
ifconfig_bin='ifconfig'

if [ $os_name == 'ubuntu' ]; then
	if [ $isinstalled == true ]; then
		if [ $os_version_int -lt 15 ]; then
			isinstalledubuntu
			initctl start runsunloginclient --system
		else
			isinstalledubuntu_hv
			systemctl start runsunloginclient.service
		fi
	fi
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	if [ $os_version_int -lt 7 ]; then
		isinstalledcentos
		if [ $isinstalled == true ]; then
			ifconfig_bin='/sbin/ifconfig'
			#/sbin/service iptables stop
			/sbin/service runsunloginclient start
		fi
	else
		isinstalledcentos_hv
		#systemctl stop firewalld.service
		systemctl start runsunloginclient.service
	fi

else
	echo 'unknown os'
fi

if [ $isinstalled == true ]; then
	
        echo "Please visit http://<this machine ip>:30080   to  configure remote client"
	echo "-------------------------------"
	echo "Sunlogin started."
fi


cd - > /dev/null
