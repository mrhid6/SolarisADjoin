
SUNOS=`uname -r`
hostname=`hostname`


ldap_SSD_file=`mktemp /tmp/ldap_ssd.XXXXX`
ldap_client_script="./files/configure_ldap_client.sh"

searchbase=`echo "DC="$domain | sed -e 's/\./,DC=/g'`

ldapsearch -h $domain_hostname"."$domain -D cn=$domain_admin_user,$basedn -w $domain_admin_pass -b $searchbase \
-s one "(|(objectCategory=Container) (objectCategory=OrganizationalUnit))" dn 2>&1| egrep -v "Unfollowed|ldap://" | \
sed 's/dn: //g' | grep -v "version: " | sort -n | egrep -v "CN=Keys,|CN=System,|CN=ForeignSecurityPrincipals,|CN=Program Data,|OU=Domain Controllers,|CN=Managed Service Accounts," | sed '/^$/d' > $ldap_SSD_file

ldap_SSD_PASSWD=""
ldap_SSD_GROUP=""

while read line; do
	ldap_SSD_PASSWD="${ldap_SSD_PASSWD}${line}?sub?(&(uidnumber=*)(objectCategory=Person));"
	ldap_SSD_GROUP="${ldap_SSD_GROUP}${line}?sub?(&(gidnumber=*)(objectCategory=Group));"
done < ${ldap_SSD_file}

ldap_SSD_PASSWD=${ldap_SSD_PASSWD::-1};
ldap_SSD_GROUP=${ldap_SSD_GROUP::-1};

rm ${ldap_SSD_file}

touch /var/ldap/ldap_client_file /var/ldap/ldap_client_cred

cat << EOF > $ldap_client_script
ldapclient manual \
-a credentialLevel=proxy \
-a authenticationMethod=simple \
-a proxyDN="$proxy_dn" \
-a proxyPassword="$proxy_pass" \
-a defaultSearchBase="$searchbase" \
-a domainName="$domain" \
-a defaultServerList="$ldapservers" \
-a attributeMap=group:userpassword=userPassword \
-a attributeMap=group:memberuid=memberUid \
-a attributeMap=group:gidnumber=gidNumber \
-a attributeMap=passwd:uid=sAMAccountName \
-a attributeMap=passwd:gecos=displayName \
-a attributeMap=passwd:gidnumber=gidNumber \
-a attributeMap=passwd:uidnumber=uidNumber \
-a attributeMap=passwd:homedirectory=unixHomeDirectory \
-a attributeMap=passwd:loginshell=loginShell \
-a attributeMap=shadow:shadowflag=shadowFlag \
-a attributeMap=shadow:userpassword=userPassword \
-a attributeMap=shadow:uid=sAMAccountName \
-a attributeMap=shadow:shadowLastChange=pwdLastSet \
-a objectClassMap=group:posixGroup=group \
-a objectClassMap=passwd:posixAccount=user \
-a objectClassMap=shadow:shadowAccount=user \
-a serviceSearchDescriptor=passwd:"$ldap_SSD_PASSWD" \
-a serviceSearchDescriptor=group:"$ldap_SSD_GROUP"
EOF


bash ${ldap_client_script}

echo "To re-run Ldap Client script: ${ldap_client_script}"

echo ""
echo "Ldap Client Config Listing:"
echo ""
ldapclient list

if [ "$SUNOS" == "5.11" ]; then
	cp files/nsswitch.ldap /etc/nsswitch.conf
	nscfg import -f svc:/system/name-service/switch:default
	sleep 1
	svccfg -s name-service/switch refresh
	svcadm refresh name-service/switch
fi
