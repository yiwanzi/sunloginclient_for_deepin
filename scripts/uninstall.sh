#!/bin/bash


echo "Sunlogin client for linux uninstaller"
echo "-------------------------------"


#change directory to script path
curpath=$(cd "$(dirname "$0")"; pwd)
cd $curpath > /dev/null

source ./common.sh

#check root
check_root "Installed Sunlogin client needs root to uninstall"

bash ./stop.sh
os_version_int=${os_version%.*}
for i in $(seq 1 10)
do
	os_version_int=${os_version_int%.*}
done

echo "Removing files"
if [ $os_name == 'ubuntu' ]; then
	if [ $os_version_int -lt 15 ]; then
		rm /etc/init/runsunloginclient.conf > /dev/null 2>&1
	else
		systemctl disable runsunloginclient.service
		rm /etc/systemd/system/runsunloginclient.service > /dev/null 2>&1
	fi

	#lightdm remove
	rm /usr/share/lightdm/lightdm.conf.d/50-slscreenagrentsvr.conf >/dev/null 2>&1
	tmp_file_name='/tmp/lightdm.conf.tmp'
	sed '/greeter-setup-script=xhost +/d' /etc/lightdm/lightdm.conf > $tmp_file_name 2> /dev/null
	if [ $? -eq 0 ]; then
		cp $tmp_file_name /etc/lightdm/lightdm.conf
		rm $tmp_file_name
	else
		echo 'no lightdm'
	fi

	#gdm remove
	tmp_file_name='/tmp/gdm_init_Default.tmp'
	sed '/xhost +/d' /etc/gdm/Init/Default > $tmp_file_name 2> /dev/null
	if [ $? -eq 0 ]; then
		cp $tmp_file_name /etc/gdm/Init/Default
		rm $tmp_file_name
	else
		echo 'no gdm'
	fi
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	if [ $os_version_int -lt 7 ]; then
		/sbin/chkconfig runsunloginclient off
		/sbin/chkconfig --del runsunloginclient
		rm /etc/init.d/runsunloginclient > /dev/null 2>&1

		#delete soft link
		for i in $(seq 0 6)
		do
			rm /etc/rc$i.d/S99slrmct > /dev/null 2>&1
			rm /etc/rc$i.d/S99slscreenagentsvr  > /dev/null 2>&1
		done
	else
		systemctl disable runsunloginclient.service
		rm /etc/systemd/system/runsunloginclient.service > /dev/null 2>&1
	fi

	#gdm remove
	tmp_file_name='/tmp/gdm_init_Default.tmp'
	sed '/xhost +/d' /etc/gdm/Init/Default > $tmp_file_name 2>/dev/null
	if [ $? -eq 0 ]; then
		cp $tmp_file_name /etc/gdm/Init/Default
		rm $tmp_file_name
	else
		echo 'no gdm'
	fi
fi

echo "Removing scripts"
rm $path_main/*.sh

echo "Removing log files"
#rm "$path_log/slrmct" -rf

echo "Removing doc files"
rm "$path_doc" -rf

echo "Removing config files"

rm "$path_etc/watch.sh"
rm /etc/orayconfig.conf

echo "Removing binaries"
rm "$path_bin/oray_rundaemon"
rm "$path_bin/sunloginclient_linux"

echo "Removing man directory"
rm "$path_main" -rf

echo "Remove Green configure files"
find ../bin/  -name orayconfig.conf |xargs rm -f

echo "Remove  temporary files"
rm /var/tmp/linux_oray_sunloginclient_2.1.lock 1>/dev/null 2>&1

echo "Sunlogin client removed :-("
cd - > /dev/null
