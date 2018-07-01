#!/bin/bash

echo "Attempting to stop sunlogin"
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
check_root "Installed Sunlogin client needs root to stop"

if [ $os_name == 'ubuntu' ]; then
	if [ $os_version_int -lt 15 ]; then
		initctl stop runsunloginclient --system
	else
		systemctl stop runsunloginclient.service
	fi
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	if [ $os_version_int -lt 7 ]; then
		/sbin/service runsunloginclient stop
	else
		systemctl stop runsunloginclient.service
	fi

else
	echo 'unknown os'

fi

killall sunloginclient_linux
rm /var/tmp/linux_oray_sunloginclient_2.1.lock  1>/dev/null 2>&1


echo "-------------------------------"
echo "Sunlogin stopped"

cd - > /dev/null
