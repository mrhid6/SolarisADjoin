#!/bin/bash



echo "################################"
echo "#     Solaris ADJoin Script    #"
echo "#  Created by Mr D Richardson  #"
echo "################################"

chmod -R +x ./*

function areyousure() {
	while true; do
		read -p "$1" val
		case $val in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) echo "Please Enter yes or no.";;
		esac
	done
}

function copy_nsswitch() {
	echo ""
	echo "Copying nsswitch.."
	cp -pr ./files/nsswitch.* /etc/.
}


areyousure "ADJoin script is about to start do you want to continue? [Y/N]: "

if [ ! -f ./variables ]; then
	bash set_variables.sh
	var_rc=$?
	if [ $var_rc == 1 ]; then
		exit 1;
	fi
fi


. ./variables

SUNOS=`uname -r`
hostname=`hostname`


if [ "$SUNOS" == "5.10" ]; then
	if [ ! -f /etc/resolv.conf ]; then
		areyousure "File: /etc/resolv.conf Doesn't exist want to fix this? [Y/N]: "
		echo "domain $domain" > /etc/resolv.conf
		echo "search $domain" >> /etc/resolv.conf
		echo "nameserver $nameserver1" >> /etc/resolv.conf
		
		if [ ! "$nameserver2" == "" ]; then
			echo "nameserver $nameserver2" >> /etc/resolv.conf
		fi
		
		echo "Created /etc/resolv.conf"	
	fi
	
	copy_nsswitch

	echo ""
	echo "Configuring NTP"
	cat ./files/ntp.conf | sed -e "s/%DCDomain/$nameserver1/g" > /etc/inet/ntp.conf
	sleep 1

	echo "Enabling NTP Client"
	svcadm enable ntp4:default
	
	echo "Syncing Time with Domain Controller"
	ntpdate -u "$nameserver1"
	
	echo ""
	echo "Time is now: "`date`
	areyousure "Is The Time Correct? [Y/N]: "
	
	echo ""
	echo "Enabling DNS client.."
	svcadm enable svc:/network/dns/client:default
	svcadm enable name-service-cache

	echo "Testing DNS Client.."
	dig $domain_hostname"."$domain +short
	dig -x $nameserver +short
	
	if [ ""`dig $hostname"."$domain +short` == "" ]; then
		echo "Error: Add This host into DNS.. Exiting.."
		exit
	fi
	
elif [ "$SUNOS" == "5.11" ]; then
	copy_nsswitch
	nscfg import -f svc:/system/name-service/switch:default
	sleep 1
	svccfg -s name-service/switch refresh
	svcadm refresh name-service/switch
	
	echo ""
	echo "Configuring NTP"
	cat ./files/ntp.conf | sed -e "s/%DCDomain/$nameserver1/g" > /etc/inet/ntp.conf
	sleep 1

	echo "Enabling NTP Client"
	svcadm enable ntp
	
	echo "Syncing Time with Domain Controller"
	ntpdate -u "$nameserver1"
	
	echo ""
	echo "Time is now: "`date`
	areyousure "Is The Time Correct? [Y/N]: "
	
	echo ""
	echo "Enabling DNS client.."
	svcadm enable svc:/network/dns/client:default
	svcadm enable name-service-cache
	svcadm enable name-service/cache
	
	svccfg -s dns/client setprop config/domain = astring: "$domain"
	svccfg -s dns/client setprop config/search = astring: "$domain"
	svccfg -s dns/client setprop config/nameserver = net_address: $nameserver1 $nameserver2
	svccfg -s dns/client:default refresh
	svccfg -s dns/client:default validate
	
	echo "Testing DNS Client.."
	dig $domain_hostname"."$domain +short
	dig -x $nameserver +short
	
	if [ ""`dig $hostname"."$domain +short` == "" ]; then
		echo "Error: Add This host into DNS.. Exiting.."
		exit 1
	fi
	
	svcadm enable ktkt_warn
	
fi

echo ""
areyousure "Do you want to add this Computer to AD? [Y/N]: "


./adjoin -f -p $domain_admin_user

adjoin_rc=$?

if [ ! $adjoin_rc == 0 ]; then
	echo "AD join was unsuccessfull! Exiting.."
	exit 1
fi
sleep 3

echo ""
echo "Configuring LdapClient.."
. ./ldapclient.sh

echo ""
echo "Restarting Ldap Client.."
svcadm disable ldap/client:default
sleep 2
svcadm enable ldap/client:default

echo ""
echo "Copying Pam.conf.."
cp -pr ./files/pam.conf /etc/.

if [ "$SUNOS" == "5.11" ]; then
	cp -pr ./files/pam.d/* /etc/pam.d/.
fi
echo ""

bash ./install_samba.sh

echo ""

read -p "Do you want to delete the variables file? [Y/N]: " val
		case $val in
			[Yy]* ) rm "./variables";;
			* ) echo "";;
		esac

echo "Completed To Test run the following:"
echo "getent passwd <user>"
