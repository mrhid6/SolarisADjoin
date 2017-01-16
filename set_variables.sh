#!/bin/sh

echo "Enter domain name of your AD domain (example: ad.atomia.com): "
read adDomain
echo "Hostname of the main domain controller (example: dc1): "
read adHostname
echo "Administrative user for the domain (example: Administrator): "
read administrator
echo "Administrative user password: "
read administratorPassword
echo "Base DN for the domain (example: cn=Users,dc=ad,dc=atomia,dc=com): "
read baseDN
echo "User to use for binding to the domain (example: PosixGuest): "
read bindUser
echo "Bind user password: "
read bindUserPassword
echo "Ldap servers ip addresses ie list of domain controllers seperated by space (example: 2.2.2.2 3.3.3.3): "
read ldapServers
echo "Name server (example: 8.8.8.8)"
read nameServer
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
nameserver="$nameServer"
EOF

echo "Done..."
