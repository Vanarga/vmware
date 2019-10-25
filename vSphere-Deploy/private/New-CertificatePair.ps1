function New-CertificatePair {
    .SYNOPSIS
		Configure Private/Public Keys for ssh authentication without password.

    .DESCRIPTION
	
    .PARAMETER CertDir

    .PARAMETER Deployment
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-CertificatePair -CertDir < > -Deployment < > -VIHandle < >

        PS C:\> New-CertificatePair 

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-CertificatePair
    #>
	[cmdletbinding()]
	param (
        [Parameter(Mandatory=$true)]
		$CertDir,
		[Parameter(Mandatory=$true)]
		$Deployment,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	$certPath	= $CertDir + "\" + $Deployment.Hostname

	$script = '[ ! -s /root/.ssh/authorized_keys ] && echo "File authorized keys does not exist or is empty."'
	$createKeyPair = $(Invoke-ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput

	if ($createKeyPair) {
    	# Create key pair for logining in to host without password.
		$commandList = $null
		$commandList = @()
		# Create and pemissions .ssh folder.
		$commandList += "mkdir /root/.ssh"
    	$commandList += "chmod 700 /root/.ssh"
    	# Create key pair for logining in to host without password.
    	$commandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.Hostname + " -q"
    	# Add public key to authorized_keys for root account and permission authorized_keys.
    	$commandList += "cat /root/.ssh/" + $Deployment.Hostname + ".pub >> /root/.ssh/authorized_keys"
		$commandList += "chmod 600 /root/.ssh/authorized_keys"

		Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

    	# Copy private and public keys to deployment folder for host.
		$filePath = $null
		$filePath = @()
		$filePath += "/root/.ssh/" + $Deployment.Hostname
		$filePath += $certPath+ "\" + $Deployment.Hostname + ".priv"
		$filePath += "/root/.ssh/" + $Deployment.Hostname + ".pub"
		$filePath += $certPath+ "\" + $Deployment.Hostname + ".pub"

    	Copy-FileToServer $filePath $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false

		# If there is no global private/public keys pair for the SSO domain hosts, create it.
    	if (-not(Test-Path $($CertDir + "\" + $Deployment.SSODomainName + ".priv"))) {
        	$commandList = $null
        	$commandList = @()
        	# Create key pair for logining in to host without password.
        	$commandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.SSODomainName + " -q"
        	# Add public key to authorized_keys for root account and permission authorized_keys.
        	$commandList += "cat /root/.ssh/" + $Deployment.SSODomainName + ".pub >> /root/.ssh/authorized_keys"

        	Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

        	$filePath = $null
        	$filePath = @()
        	$filePath += "/root/.ssh/" + $Deployment.SSODomainName
    		$filePath += $CertDir + "\" + $Deployment.SSODomainName + ".priv"
        	$filePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
        	$filePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"

        	Copy-FileToServer $filePath $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false
    	} else {
			$filePath = $null
			$filePath = @()
	        $filePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
	        $filePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
	        Copy-FileToServer $filePath $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $true
	        $commandList = $null
	        $commandList = @()
	        # Add public cert to authorized keys.
        	$commandList += "cat /root/.ssh/$($Deployment.SSODomainName).pub >> /root/.ssh/authorized_keys"
        	Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
		}
	}
}