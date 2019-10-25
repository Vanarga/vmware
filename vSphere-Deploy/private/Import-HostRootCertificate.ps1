function Import-HostRootCertificate {
    .SYNOPSIS
		Download the Node self signed certificate and install it in the local trusted root certificate store.

    .DESCRIPTION

    .PARAMETER CertPath
	
    .PARAMETER Deployment
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertPath < > -Deployment < > -VIHandle < >

        PS C:\> Import-HostRootCertificate

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Import-HostRootCertificate
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$CertPath,
		[Parameter(Mandatory=$true)]
		$Deployment,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	Write-SeparatorLine

	$rootCertPath = $CertPath+ "\" + $Deployment.Hostname.Split(".")[0] + "_self_signed_root_cert.crt"

	$commandList 	= $null
	$commandList 	= @()
	$commandList 	+= "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`' | grep `'CN(id):`'"

	$Certid = $(Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("")[2]

	$commandList 	= $null
	$commandList 	= @()
	$commandList    += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert get --id $Certid --outcert /root/vcrootcert.crt --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"

	Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	$filePath = $null
	$filePath = @()
	$filePath += "/root/vcrootcert.crt"
	$filePath += $rootCertPath

	Copy-FileToServer $filePath $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false

	Import-Certificate -FilePath $rootCertPath -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

	Write-SeparatorLine
}