Set-executionpolicy ByPass
Import-Module ActiveDirectory

New-ADObject -Name auto_master -Path "%AUTOFS_DN" -Type nisMap -OtherAttributes @{'nisMapName'='auto_master'}
New-ADObject -Name /home -Path "CN=auto_master,%AUTOFS_DN" -Type nisObject -OtherAttributes @{'nisMapName'='auto_master' ; 'nisMapEntry'='auto_home'}

New-ADObject -Name auto_home -Path "%AUTOFS_DN" -Type nisMap -OtherAttributes @{'nisMapName'='auto_home'}
New-ADObject -Name test -Path "CN=auto_home,OU=autofs,$basedn" -Type nisObject -OtherAttributes @{'nisMapName'='auto_home'; 'nisMapEntry'='192.168.10.20:/export/home/test'}



New-ADObject -Name /apps -Path "CN=auto_master,OU=autofs,$basedn" -Type nisObject -OtherAttributes @{'nisMapName'='auto_master' ; 'nisMapEntry'='auto_apps'}
New-ADObject -Name auto_apps -Path "OU=autofs,$basedn" -Type nisMap -OtherAttributes @{'nisMapName'='auto_apps'}
New-ADObject -Name test -Path "CN=auto_apps,OU=autofs,$basedn" -Type nisObject -OtherAttributes @{'nisMapName'='auto_home'; 'nisMapEntry'='192.168.10.20:/export/apps/test'}