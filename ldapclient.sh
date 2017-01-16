
touch /var/ldap/ldap_client_file /var/ldap/ldap_client_cred

searchbase=`echo "DC="$domain | sed -e 's/\./,DC=/g'`

ldapclient manual \
-a credentialLevel=self \
-a authenticationMethod=sasl/gssapi \
-a defaultSearchBase=$searchbase \
-a domainName=$domain \
-a defaultServerList=$ldapservers \
-a attributeMap=passwd:gecos=cn \
-a attributeMap=passwd:homedirectory=unixHomeDirectory \
-a objectClassMap=group:posixGroup=group \
-a objectClassMap=passwd:posixAccount=user \
-a objectClassMap=shadow:shadowAccount=user \
-a serviceSearchDescriptor=passwd:$basedn?sub \
-a serviceSearchDescriptor=group:$basedn?sub

echo ""
echo "Ldap Client Config Listing:"
echo ""
ldapclient list