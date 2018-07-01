#!/bin/bash

#value1="home"
#value2="${value1}""="
#echo $value2

depends=$(ldd ./bin/64/sunloginclient_linux |grep "not found" |cut -d " " -f 1)

#echo $depends

function centos_install
{
	OLD_IFS="$IFS" 
	IFS=" " 
	arr=($1) 
	IFS="$OLD_IFS"
	packets=""
	for x in ${arr[@]}
	do
		#x=$(echo ${x// /})
		#echo $x
		if [ "$x" = "libstdc++.so.6" ]; then
			packets="${packets}"" libstdc++.x86_64"
		elif [ "$x" = "libgcc_s.so.1" ]; then
                        packets="${packets}"" libgcc.x86_64"
		elif [ "$x" = "libc.so.6" ]; then
                        packets="${packets}"" glibc.x86_64"
		elif [ "$x" = "libuuid.so.1" ]; then
			packets="${packets}"" libuuid.x86_64"
		elif [ "$x" = "libX11.so.6" ]; then
			packets="${packets}"" libX11.x86_64"
		elif [ "$x" = "libXtst.so.6" ]; then
			packets="${packets}"" libXtst.x86_64"
		elif [ "$x" = "libXrandr.so.2" ]; then
                        packets="${packets}"" libXrandr.x86_64"
		elif [ "$x" = "libXinerama.so.1" ]; then
                        packets="${packets}"" libXinerama.x86_64"
		elif [ "$x" = "libxcb.so.1" ]; then
                        packets="${packets}"" libxcb.x86_64"
		elif [ "$x" = "libXext.so.6" ]; then
                        packets="${packets}"" libXext.x86_64"
		elif [ "$x" = "libXi.so.6" ]; then
                        packets="${packets}"" libXi.x86_64"
		elif [ "$x" = "libXrender.so.1" ]; then
                        packets="${packets}"" libXrender.x86_64"
		elif [ "$x" = "libXau.so.6" ]; then
                        packets="${packets}"" libXau.x86_64"
		fi
	done
	echo $packets
}

function ubuntu_install
{
	OLD_IFS="$IFS" 
	IFS=" " 
	arr=($1) 
	IFS="$OLD_IFS"
	packets=""
	for x in ${arr[@]}
	do
		#x=$(echo ${x// /})
		#echo $x
		if [ "$x" = "libstdc++.so.6" ]; then
			packets="${packets}"" libstdc++6"
		elif [ "$x" = "libgcc_s.so.1" ]; then
                        packets="${packets}"" libgcc1"
		elif [ "$x" = "libc.so.6" ]; then
                        packets="${packets}"" libc6"
		elif [ "$x" = "libuuid.so.1" ]; then
			packets="${packets}"" libuuid1"
		elif [ "$x" = "libX11.so.6" ]; then
			packets="${packets}"" libx11-6"
		elif [ "$x" = "libXtst.so.6" ]; then
			packets="${packets}"" libxtst6"
		elif [ "$x" = "libXrandr.so.2" ]; then
                        packets="${packets}"" libxrandr2"
		elif [ "$x" = "libXinerama.so.1" ]; then
                        packets="${packets}"" libxinerama1"
		elif [ "$x" = "libxcb.so.1" ]; then
                        packets="${packets}"" libxcb1"
		elif [ "$x" = "libXext.so.6" ]; then
                        packets="${packets}"" libxext6"
		elif [ "$x" = "libXi.so.6" ]; then
                        packets="${packets}"" libxi6"
		elif [ "$x" = "libXrender.so.1" ]; then
                        packets="${packets}"" libxrender1"
		elif [ "$x" = "libXau.so.6" ]; then
                        packets="${packets}"" libxau6"
		fi
	done
	echo $packets
}

packet=''

if [ $os_name == 'ubuntu' ] || [ $os_name == 'deepin' ]; then
	packet=$(ubuntu_install "$depends")
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	packet=$(centos_install "$depends")
fi
