
function echoAndExit
{
	echo -n 'Error:'
	echo $1
	echo 'Installation failed'
	exit 1
}

#check root
function check_root
{
	if [ $(whoami) != 'root' ]; then
		if [ "$1" == "" ]; then
			echo 'Sunlogin client needs root to complete installation'
		else
			echo "$1"
		fi
		exit 1
	fi
}

function killallsunloginclient
{
	if [[ $(ps -A | grep sunloginclient_) != "" ]]; then
		killall sunloginclient_linux
	fi
}

path_main='/usr/local/sunlogin'
path_bin="$path_main/bin"
path_etc="$path_main/etc"
path_doc="$path_main/doc"
path_log="$path_main/var/log"

#get operation system info
function get_os_name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='centos'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='redhat'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    echo $DISTRO;
}

os_name=$(get_os_name)
os_version='0.0'

if [ $os_name == 'ubuntu' ]; then
	os_version=`cat /etc/issue | cut -d' ' -f2`
elif [ $os_name == 'Deepin' ]; then
	os_version=`cat /etc/issue | cut -d' ' -f3`
elif  [ "$os_name" == "centos" ] || [ $(echo $os_name |grep redhat) != "" ] ; then
	os_version=`rpm -q centos-release|cut -d- -f3`
fi

os_name=$(echo $os_name | tr [A-Z] [a-z])
os_bits=$(getconf LONG_BIT)

#echo $os_name
#echo $os_version
