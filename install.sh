#!/bin/bash

echo "Sunlogin client for linux installer by oray.com"
echo "-------------------------------"

read -p "Install sunlogin client to your system?(Y/n)" willinstall
if [ -z $willinstall ]; then
	willinstall='Y'
fi
if [ $willinstall != 'Y' ] && [ $willinstall != 'y' ]; then
	echo $willinstall
	exit
fi


#change directory to script path
curpath=$(cd "$(dirname "$0")"; pwd)
cd $curpath > /dev/null

source ./scripts/common.sh

#check root
check_root


source ./scripts/depends.sh

echo "Checking system dependencies...."
if [ -z "$depends" ]; then
	echo "OK."
else
	echo "Sunlogin requires following components to be installed to your system:"
	echo $packet
	echo "-------------------------------"
	read -p "Install all dependencies automatically(Y/n)" install
	if [ -z $install ]; then
        	install='Y'
	fi
	if [ $install != 'Y' ] && [ $install != 'Y' ]; then
		echo "Please install the missing components manualy"
		exit
	else
		yum install -y $packet
	fi
fi

#kill all runing sunloginclient_linux
killall sunloginclient_linux


function old_version_lightdm_init_create
{
	src_str='\[SeatDefaults\]'
	dest_str='greeter-setup-script=xhost +'
	file_name='/etc/lightdm/lightdm.conf'
	tmp_file_name='/tmp/lightdm.conf.tmp'

	if [ ! -f $file_name ]; then
		echo "no $file_name file"
		return 1
	fi

	if [ $(grep "'$dest_str'" $file_name) ]; then
		echo 'already replace'
		return 0
	fi

	if [ $(grep "$src_str" $file_name) ]; then
		sed "s/$src_str/$src_str\n$dest_str/" $file_name > $tmp_file_name
		cp $tmp_file_name $file_name
		rm $tmp_file_name
		return 0
	else
		echo "has no [$src_str]"
		return 1
	fi
	return 1
}

function gdm_init_create
{
	dest_str='xhost +'
	file_name='/etc/gdm/Init/Default'

	if [ ! -f $file_name ]; then
		echo "no $file_name file"
		return 1
	fi

	result=$(grep "$dest_str" "$file_name")
	if [ ! "$result" == '' ]; then
		echo 'already replace'
		return 0
	fi

	sed "2 i$dest_str" -i $file_name

	return 0

}

if [ $os_name == 'ubuntu' ] || [ $os_name == 'deepin' ] || [ $os_name == 'centos' ] || [ $(echo $os_name |grep redhat) != "" ]; then
	echo 'check operate system OK'
else
	echoAndExit 'unknown OS it not impl'
fi
	

mkdir $path_bin -p || echoAndExit "create bin directory failed : $path_bin"
echo "copy oray_rundaemon 			to $path_bin"
cp ./bin/$os_bits/oray_rundaemon $path_bin/oray_rundaemon || echoAndExit 'can not copy oray_rundaemon file'
echo "copy sunloginclient_linux 		to $path_bin"
cp ./bin/$os_bits/sunloginclient_linux $path_bin || echoAndExit 'can not copy sunloginclient_linux file'
echo "copy ethtool 				to $path_bin"
cp ./bin/$os_bits/ethtool $path_bin || echoAndExit 'can not copy ethtool file'
echo "copy accpet.sh 				to $path_bin"
cp ./scripts/accpet.sh $path_bin || echoAndExit 'can not copy accpet.sh file'
chmod +x $path_bin/*.sh
os_version_int=${os_version%.*}
for i in $(seq 1 10)
do
	os_version_int=${os_version_int%.*}
done


mkdir $path_etc -p || echoAndExit "create etc directory failed : $path_etc"
echo "copy watch.sh 				to $path_etc"
cp ./scripts/watch.sh $path_etc || echoAndExit 'can not copy runsunlogin.sh file'
chmod +x $path_etc/watch.sh

echo "copy start.sh 				to $path_main"
cp ./scripts/start.sh $path_main/
echo "copy common.sh 				to $path_main"
cp ./scripts/common.sh $path_main/
echo "copy stop.sh 				to $path_main"
cp ./scripts/stop.sh $path_main/
echo "copy uninstall.sh 			to $path_main"
cp ./scripts/uninstall.sh $path_main/
#echo "copy install.sh 			to $path_main"
#cp ./install.sh $path_main/
chmod +x $path_main/*.sh
chmod +x ./install.sh

cp  README $path_main/

#echo "create init"
if [ $os_name == 'ubuntu' ] || [ $os_name == 'deepin' ]; then
	cp ./scripts/lightdm.conf /usr/share/lightdm/lightdm.conf.d/50-slscreenagrentsvr.conf > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo 'no pos /usr/share/lightdm, so modify base lightdm.conf file'
		old_version_lightdm_init_create
		if [ $? -ne 0 ]; then
			echo 'no lightdm.conf file, so use gdm'
			gdm_init_create
			if [ $? -ne 0 ]; then
				echoAndExit 'create lightdm init failed'
			fi
		fi
	fi
	if [ $os_version_int -lt 15 ]; then
		cp ./scripts/runsunloginclient.conf /etc/init/runsunloginclient.conf || echoAndExit 'can not copy init file runsunloginclient.conf'
	else
		cp ./scripts/runsunloginclient.service /etc/systemd/system/runsunloginclient.service || echoAndExit 'can not copy init file runsunloginclient.service'
		systemctl enable runsunloginclient.service
	fi

	#echo "Sunlogin client installed. Enjoy!"
	cd - > /dev/null

	#echo "get lightdm X Authority"
	#xhost + >/dev/null 2>&1 || service lightdm restart || service gdm restart

elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	gdm_init_create
	if [ $os_version_int -lt 7 ]; then
		echo "copy init_runsunloginclient 		to /etc/init.d/"
		cp ./scripts/init_runsunloginclient /etc/init.d/runsunloginclient || echoAndExit 'can not copy init file init_runsunloginclient'
		chmod +x /etc/init.d/runsunloginclient
		#create soft link	
		for i in $(seq 0 6)
		do
			ln -s /etc/init.d/runsunloginclient /etc/rc$i.d/S99runsunloginclient > /dev/null 2>&1
		done
		/sbin/chkconfig --add runsunloginclient
		/sbin/chkconfig runsunloginclient on
	else
		echo "copy runsunloginclient.service 			to /etc/systemd/system/"
		cp ./scripts/runsunloginclient.service /etc/systemd/system/runsunloginclient.service || echoAndExit 'can not copy init file runsunloginclient.service'
		systemctl enable runsunloginclient.service
	fi

	#echo "Sunlogin client installed in $path_main Enjoy!"
	cd - > /dev/null

	#echo "get gdm X Authority"
	#xhost + >/dev/null 2>&1 || /usr/sbin/gdm-restart
else

	echo 'unknown OS is not impl'
fi


read -p "Start sunlogin now(Y/n)" startnow
if [ -z $startnow ]; then
	startnow='Y'
fi
if [ $startnow == 'Y' ] || [ $startnow == 'y' ]; then
        /usr/local/sunlogin/start.sh

	read -p "Configure your sunlogin client now(Y/n)" confignow
	if [ -z $confignow ]; then
                confignow='Y'
        fi
	if [ $confignow != 'Y' ] && [ $confignow != 'y' ]; then
        	echo "use your browser to config or run '/usr/local/sunlogin/bin/sunloginclient_linux --mod=shell' to config interactively."
	else
		/usr/local/sunlogin/bin/sunloginclient_linux --mod=shell
	fi
fi

echo "Successfully installed Sunlogin client ver 9.6"
echo "-------------------------------"
echo "Start:     /usr/local/sunlogin/start.sh"
echo "Stop:      /usr/local/sunlogin/stop.sh"
echo "Uninstall: /usr/local/sunlogin/uninstall.sh"
echo "-------------------------------"
echo "Configure(via shell):   /usr/local/sunlogin/bin/sunloginclient_linux --mod=shell"
echo "Configure(via browser): Please visit <this machine ip>:30080"
echo "-------------------------------"
echo "Safety note: Block 30080/tcp after configuration."
echo "-------------------------------"
echo "Note:"
echo "Sunlogin remote desktop for linux needs "lightdm" to be installed, otherwise functions like "SSH, RemoteFile" will still work,if it don't work, you need install the package manually."
echo "Step"
echo "1. apt-get install lightdm"
echo "2. click OK on the pop dialog, select "lightdm" as your default display manager"
echo "-------------------------------"
echo "Enjoy."

