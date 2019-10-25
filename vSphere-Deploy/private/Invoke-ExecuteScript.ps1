function Invoke-ExecuteScript {
    .SYNOPSIS
		Execute a script via Invoke-VMScript.

    .DESCRIPTION

    .PARAMETER Script
	
    .PARAMETER Hostname
	
    .PARAMETER Username
	
    .PARAMETER Password
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-ExecuteScript -Script < > -Hostname < > -Username < > -VIHandle < >

        PS C:\> Invoke-ExecuteScript

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-ExecuteScript
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Script,
		[Parameter(Mandatory=$true)]
		$Hostname,
		[Parameter(Mandatory=$true)]
		$Username,
		[Parameter(Mandatory=$true)]
		$Password,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	Write-SeparatorLine

	$Script | ForEach-Object {Write-Output $_} | Out-String

	Write-SeparatorLine

	$output = Invoke-VMScript -ScriptText $(if ($Script.count -gt 1) {$Script -join(";")} else {$Script}) -vm $Hostname -GuestUser $Username -GuestPassword $Password -Server $VIHandle

	return $output
}