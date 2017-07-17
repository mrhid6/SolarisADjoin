
SUNOS=`uname -r`
hostname=`hostname`

touch /var/ldap/ldap_client_file /var/ldap/ldap_client_cred

searchbase=`echo "DC="$domain | sed -e 's/\./,DC=/g'`

ldapclient manual \
-a credentialLevel=proxy \
-a authenticationMethod=simple \
-a proxyDN=$proxy_dn \
-a proxyPassword=$proxy_pass \
-a defaultSearchBase=$searchbase \
-a domainName=$domain \
-a defaultServerList=$ldapservers \
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
-a serviceSearchDescriptor=passwd:$basedn?sub \
-a serviceSearchDescriptor=group:$basedn?sub

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
