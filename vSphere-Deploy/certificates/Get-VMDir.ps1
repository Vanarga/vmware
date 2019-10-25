function Get-VMDir {
    <#
    .SYNOPSIS
		Displays the currently used VMDir certificate via OpenSSL.

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Get-VMDir

        PS C:\> Get-VMDir

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Get-VMDir
    #>
	[cmdletbinding()]
	$computerName = Get-WmiObject win32_computersystem
	$defFQDN = "$($computerName.Name).$($computerName.Domain)".ToLower()
	$vmDirHost = $(
		Write-Host "Do you want to dispaly the VMDir SSL certificate of $defFQDN ?"
		$inputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		if ($inputFQDN) {
			$inputFQDN
		} else {
			$defFQDN
		}
	)
	Invoke-OpenSSL "s_client -servername $vmDirHost -connect `"${VMDirHost}:636`""
}