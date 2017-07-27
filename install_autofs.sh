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


areyousure "Do You Want To Install AutoFS? [Y/N]: "

. ./variables


if [ "$autofs_dn" == "" ]; then
	echo "Whats the location of the Automounters in AD (exmaple ou=autofs,dc=ad,dc=atomia,dc=com)"
	read autofs_dn
	
	echo "autofs_dn=\"${autofs_dn}\"" >> ./variables
fi


while true; do
	clear
	echo "Enter list of automounters, [F] to finish (example: auto_apps): "
	echo "Current List: ${automounters_list}"
	read automounter
	
	if [ "$automounter" == "f" ]; then
		break;
	elif [ ! "$automounter" == "" ]; then
		automounters_list="${automounters_list} "$automounter
	fi
done


grep -v "automounters_list" ./variables > ./variables.2
mv ./variables.2 ./variables

echo "automounters_list=\"${automounters_list}\"" >> ./variables

temp_ldapmod_file=`mktemp /tmp/ldapmod.XXXXXXX`

printf "ldapclient mod " > ${temp_ldapmod_file}

check=`ldapclient list | grep auto_master | wc -l`
if [ $check -eq 0 ]; then
		printf " \\" >> ${temp_ldapmod_file}
		printf "\n" >> ${temp_ldapmod_file}
	cat ./files/default_autofs_ldap.conf >> ${temp_ldapmod_file};
fi

for autofs in $automounters_list; do

	check=`ldapclient list | grep ${autofs} | wc -l`
	if [ $check -eq 0 ]; then
		printf " \\" >> ${temp_ldapmod_file}
		printf "\n-a \"serviceSearchDescriptor=${autofs}:cn=${autofs},${autofs_dn}\" \\" >> ${temp_ldapmod_file}
		printf "\n-a objectclassMap=${autofs}:automount=nisObject \\" >> ${temp_ldapmod_file}
		printf "\n-a attributeMap=${autofs}:automountMapName=nisMapName \\" >> ${temp_ldapmod_file}
		printf "\n-a attributeMap=${autofs}:automountKey=cn \\" >> ${temp_ldapmod_file}
		printf "\n-a attributeMap=${autofs}:automountInformation=nisMapEntry" >> ${temp_ldapmod_file}
	fi
done

printf "\n" >> ${temp_ldapmod_file}

cat ${temp_ldapmod_file} | sed "s/%AUTOFS_DN/${autofs_dn}/g" > "${temp_ldapmod_file}.2"
mv "${temp_ldapmod_file}.2" ${temp_ldapmod_file}

bash ${temp_ldapmod_file}

rm ${temp_ldapmod_file}



while true; do
	read -p "Do you want to generate PowerShell Commands? [Y/N]: " val
	case $val in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please Enter yes or no.";;
	esac
done
