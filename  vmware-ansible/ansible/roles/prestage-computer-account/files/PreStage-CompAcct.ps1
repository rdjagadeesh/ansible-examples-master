#PreStage-CompAcct.ps1
#Nigel Benton
#1.0 29/1/18
#1.1 2/2/18 additional logging info added
#1.2 7/2/18 added additional adsi commands that were needed
#1.3 31/8/18 Windows 2016 servers in cloud need to go into a different OU


Param(
$Computer,
$Domain,
$OS,
$Location="FH"
)

"[Powershell] $Computer to be pre staged in the $Domain AD."
"[Powershell] $Computer OS is $OS."
"[Powershell] $Computer resides in $Location ."



switch ($Domain)
{
    'uk.experian.local' {$Domain = "DC=uk,DC=experian,DC=local"}
    'uk.experian.staging' {$Domain = "DC=uk,DC=experian,DC=staging"}
    'gdc.local' {$Domain = "DC=gdc,DC=local"}
    'ipani.uk.experian.com' {$Domain = "DC=ipani,DC=uk,DC=experian,DC=com"}
    'workgroup' {"[Powershell] Server in a workgroup so just exit.";exit 0}
    
    Default {"[Poweshell] Script does not support the $Domain domain so exit with an error.";exit 1}
}

switch ($OS)
{
    'WINDOWS2008X86' {$OSPath = "OU=Servers,OU=Systems"}
    'WINDOWS2008X64' {$OSPath = "OU=Servers,OU=Systems"}
    'WINDOWS2008R2'  {$OSPath = "OU=Servers,OU=Systems"}
    
    'WINDOWS2012'    {$OSPath = "OU=Windows Server 2012 Member Servers,OU=Servers,OU=Systems"}
    'WINDOWS2012R2'  {$OSPath = "OU=Windows Server 2012 Member Servers,OU=Servers,OU=Systems"}
        
	
	'WINDOWS2016'
	{
	
	if($Location -eq "AWS"){$OSPath = "OU=Cloud Servers,OU=Windows Server 2016 Member Servers,OU=Servers,OU=Systems"}
	
	Else{$OSPath = "OU=Windows Server 2016 Member Servers,OU=Servers,OU=Systems"}
	
	}
		
		
    Default {"[Poweshell] Script does not support the $OS os so exit with an error.";exit 1}
}


#Test if computer object already exists

[ADSI]$CO = "LDAP://cn=$Computer,$OSPath,$Domain"

if($CO.Path -eq "LDAP://cn=$Computer,$OSPath,$Domain")
{
"[Powershell] $Computer computer account already exists at: LDAP://cn=$Computer,$OSPath,$Domain so no need to create."
exit 0
}

"[Powershell] $Computer computer account does not already exist at: LDAP://cn=$Computer,$OSPath,$Domain so need to create."

[ADSI]$OU = "LDAP://$OSPath,$Domain"
$new = $OU.Create("computer","CN=$Computer")
$new.Put("sAMAccountName",$Computer + "$") # A dollar sign must be appended to the end of every computer sAMAccountName.
$new.Put("userAccountControl", 4128) 
$new.setinfo()

#Test if computer object was created successfuly

[ADSI]$CO = "LDAP://cn=$Computer,$OSPath,$Domain"

if($CO.Path -eq "LDAP://cn=$Computer,$OSPath,$Domain")
{
"[Powershell] $Computer computer account was created successfuly at: LDAP://cn=$Computer,$OSPath,$Domain ."
exit 0
}
Else
{
"[Powershell] $Computer computer account was not created successfuly at: LDAP://cn=$Computer,$OSPath,$Domain ."
exit 1
}
