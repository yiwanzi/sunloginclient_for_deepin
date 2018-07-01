#!/bin/bash

startsunloginclient() {
	echo "start run sunloginclient"
	/usr/local/sunlogin/bin/sunloginclient_linux --mod=service
}

checksunloginclient(){
	psid=$(ps -ef | grep sunloginclient_linux | grep -v grep | grep -v $0 | awk '{print $2}')
	if [ -z $psid ]; then
	startsunloginclient
	fi
}

checksunloginclient
