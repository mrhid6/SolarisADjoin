# Solaris Active Directory Join Script

Intended for Solaris 10 (update 11) and Solaris 11.3 and above.

### Installation

* Add a Solaris Client FQDN A Record into Active Directory DNS servers.
* (Optional) Add a Bind User in Active Directory e.g PosixGuest.
  - Can use administrator account as bind user.
* Copy files to Solaris client.
* Finally Run: `bash ./RunMe.sh`

### Whats Next

If you are running Active Directory on Windows server 2008 R2 and below you should install the **Identity Management for UNIX** feature. 
This will allow you the ablility to attach Unix variables on to the AD User all on a tab in the users properties. 

If you are running Active Directory on Windows Server 2012 and up the **Identity Management for UNIX** feature has been removed.
You can still add Unix variables to AD users by going to the **Attribute Editor** tab.

The variables you can attach to the AD Users are as follows:
* uid
* uidNumber
* gidNumber
* unixHomeDirectory
* loginShell

To check if everything has been done correctly do the following:
```
getent passwd <user>
ldaplist -vl passwd <user>
```

### Disclaimer
This script has only been tested on Solaris 10 (Update 11) and Solaris 11.3.
