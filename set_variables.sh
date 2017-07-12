#!/bin/bash
clear
echo -e "Enter domain name of your AD domain (example: ad.atomia.com): "
read adDomain

clear
echo -e "Hostname of the main domain controller (example: dc1): "
read adHostname

clear
echo -e "Administrative user for the domain (example: Administrator): "
read administrator

clear
echo -e "Administrative user password: "
read -s administratorPassword

clear
echo -e "Base DN for the domain (example: cn=Users,dc=ad,dc=atomia,dc=com): "
read baseDN

while true; do
	clear
	read -p "Is bind user same as Administrative user? [Y/N]:" yn
	case $yn in 
		[Yy]* ) bindUser=$administrator;bindUserPassword=$administratorPassword; break;;
		[Nn]* ) clear; echo "User to use for binding to the domain (example: PosixGuest): "; read bindUser; clear; echo -e "Bind user password: "; read -s bindUserPassword; break ;;
		* ) echo "Please Enter yes or no.";;
	esac
done

clear
echo "Ldap servers ip addresses ie list of domain controllers seperated by space (example: 2.2.2.2 3.3.3.3): "
read ldapServers

while true; do
	clear
	echo "Name server 1 (example: 8.8.8.8): "
	read nameServer1
	if [ "$nameServer1" == "" ]; then
		echo "ERROR: Please enter Primary Nameserver!"
	else
		break;
	fi
done

echo "Name server 2 (example: 8.8.8.8): "
read nameServer2

clear
echo "Generating variables file based on your input..."

cat > variables <<EOF
domain="$adDomain"
domain_hostname="$adHostname"
domain_admin_user="$administrator"
domain_admin_pass="$administratorPassword"
basedn="$baseDN"
binduser="$bindUser"
bindpass="$bindUserPassword"
ldapservers="$ldapServers"
nameserver1="$nameServer1"
nameserver2="$nameServer2"
EOF

echo "Done..."
