function Rename-VMDir {
    <#
    .SYNOPSIS
		Renames SSL certificate files to those used by VCSA.

    .DESCRIPTION

    .PARAMETER CertDir
	
    .EXAMPLE
        The example below shows the command line use with Parameters.

        Rename-VMDir -CertDir < >

        PS C:\> Rename-VMDir

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Rename-VMDir
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$CertDir
	)
	# Renames SSL certificate files to those used by VCSA
	Rename-Item $CertDir\VMDir\VMDir.cer vmdircert.pem
	Rename-Item $CertDir\VMDir\VMDir.priv vmdirkey.pem
	Write-Host "Certificate files renamed. Upload \VMDir\vmdircert.pem and \VMDir\vmdirkey.pem" -ForegroundColor Yellow
	Write-Host "to VCSA at /usr/lib/vmware-dir/share/config" -ForegroundColor Yellow
}