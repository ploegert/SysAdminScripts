<#
.SYNOPSIS
	Connect to Office 365 to manage admin setting. Optional save credentials for autonomous execution

.DESCRIPTION
	Connect to Office 365. You can store your credentials in the script root. When 
	saved the script will connect automaticaly. if no credentials are found it will ask for them.

.REQUIREMENTS
	Install the Microsoft Online Services Sign-In Assistant
	https://www.microsoft.com/en-us/download/details.aspx?id=41950

	Install the Windows Azure Active Directory Module
	https://go.microsoft.com/fwlink/p/?linkid=236297

.EXAMPLE
	Connecting to Office 365

	.\ConnectTo-O365.ps1

.EXAMPLE
	Save credentials in the script root

	.\ConnectTo-O365.ps1 -config
   
.NOTES
	Version:        1.0
	Author:         R. Mens
	Blog:			http://lazyadmin.nl
	Creation Date:  29 mrt 2017
	
.LINK
	
#>
#-----------------------------------------------------------[Execution]------------------------------------------------------------
[CmdletBinding()]
PARAM(	
	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$false)]
	[switch]$config=$false
)
BEGIN
{
	$uaPath = "$PSScriptRoot\useraccount.txt"
	$ssPath = "$PSScriptRoot\securestring.txt"
}
PROCESS
{
	If ($config)
	{
		#create securestring and store credentials
		Write-Host 'Running in config mode, storing credentials in script root location' -ForegroundColor Yellow
		$username = Read-Host "Enter your email address"	
		$secureStringPwd = Read-Host -assecurestring "Please enter your password"

		#Storing password as a securestring
		$secureStringText = $secureStringPwd | ConvertFrom-SecureString 
		Set-Content $ssPath $secureStringText

		#Storing username
		Set-Content $uaPath $username
	}
	Else
	{
		#Check if a securestring password is stored in the script root
		If (Test-Path $ssPath) 
		{
			$securePwd = Get-Content $ssPath | ConvertTo-SecureString
		}

		#Check if useraccount is stored in the script root
		If (Test-Path $uaPath)
		{
			$username = Get-Content $uaPath
		}

		#If the useraccount or password is empty, ask for the credentials
		if (!$securePwd -or !$username)
		{
			$username = Read-Host "Enter your email address"
			$securePwd = Read-Host -assecurestring "Please enter your password"
		}
		
		#Create credential object
		$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

		#Connect to Office 365
		Connect-MsolService  -Credential $credObject
	}	
}