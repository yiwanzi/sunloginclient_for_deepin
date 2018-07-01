#!/bin/bash
tcp_linenumber=''
udp_linenumber=''
function check_root
{
	if [ $(whoami) != 'root' ]; then
		if [ "$1" == "" ]; then
			echo 'Need root to run'
		else
			echo "$1"
		fi
		exit 1
	fi
}

check_root

if [ $# -lt 3 ] ;then
	echo Lock of  parameters
	exit
fi
if [ $1 == "stop" ]; then
	tcp_linenumber=$(iptables -nL INPUT --line-number | grep tcp | grep $2 |awk '{print $1}' |head -n 1) 
	if [ $tcp_linenumber ]; then
		iptables -D INPUT $tcp_linenumber
	fi 
	udp_linenumber=$(iptables -nL INPUT --line-number | grep udp | grep $3 |awk '{print $1}' | head -n 1) 
	if [ $udp_linenumber ]; then
		iptables -D INPUT $udp_linenumber
	fi 
else
	iptables -A INPUT -p tcp --dport $2 -j ACCEPT 
	iptables -A INPUT -p udp --dport $3 -j ACCEPT
fi
