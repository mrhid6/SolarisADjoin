#!/bin/bash

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

if [ ! -f ./variables ]; then
	bash set_variables.sh
	var_rc=$?
	if [ $var_rc == 1 ]; then
		exit 1;
	fi
fi


areyousure "Do You Want To Install Samba? [Y/N]: "

. ./variables

smbadm join -u $domain_admin_user $domain