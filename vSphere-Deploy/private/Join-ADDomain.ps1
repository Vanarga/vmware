function Join-ADDomain {
    <#
    .SYNOPSIS
		Join the VCSA to the Windows AD Domain.

    .DESCRIPTION

    .PARAMETER Deployment
	
    .PARAMETER ADInfo
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Join-ADDomain -Deployment < > -ADInfo < > -VIHandle < >

        PS C:\> Join-ADDomain

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Join-ADDomain
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Deployment,
		[Parameter(Mandatory=$true)]
		$ADInfo,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	$pscDeployments	= @("tiny","small","medium","large","infrastructure")

	Write-Output "== Joining $($Deployment.vmName) to the windows domain ==" | Out-String

	Write-SeparatorLine

	$commandList = $null
	$commandList = @()
	$commandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
	$commandList += 'export VMWARE_LOG_DIR=/var/log'
	$commandList += 'export VMWARE_DATA_DIR=/storage'
	$commandList += 'export VMWARE_CFG_DIR=/etc/vmware'
	$commandList += '/usr/bin/service-control --start --all --ignore'
	$commandList += "/opt/likewise/bin/domainjoin-cli join " + $ADInfo.ADDomain + " " + $ADInfo.ADJoinUser + " `'" + $ADInfo.ADJoinPass + "`'"
	$commandList += "/opt/likewise/bin/domainjoin-cli query"

	# Excute the commands in $commandList on the vcsa.
	Invoke-ExecuteScript $commandList $Deployment.vmName "root" $Deployment.VCSARootPass $VIHandle

	Restart-VMGuest -VM $Deployment.vmName -Server $VIHandle -Confirm:$false

	# Write separator line to transcript.
	Write-SeparatorLine

	# Wait 60 seconds before checking availability to make sure the vcsa is booting up and not in the process of shutting down.
	Start-Sleep -s 60

	# Wait until the vcsa is Get-URLStatus.
	Get-URLStatus $("https://" + $Deployment.Hostname)

	# Write separator line to transcript.
	Write-SeparatorLine

	# Check domain status.
	$commandList = $null
	$commandList = @()
	$commandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
	$commandList += 'export VMWARE_LOG_DIR=/var/log'
	$commandList += 'export VMWARE_DATA_DIR=/storage'
	$commandList += 'export VMWARE_CFG_DIR=/etc/vmware'
	$commandList += '/usr/bin/service-control --start --all --ignore'
	$commandList += "/opt/likewise/bin/domainjoin-cli query"

	# Excute the commands in $commandList on the vcsa.
	Invoke-ExecuteScript $commandList $Deployment.vmName "root" $Deployment.VCSARootPass $VIHandle

	# if the vcsa is the first PSC in the vsphere domain, set the default identity source to the windows domain,
	# add the windows AD group to the admin groups of the PSC.
	$commandList = $null
	$commandList = "/opt/likewise/bin/ldapsearch -h " + $Deployment.Hostname + " -w `'" + $Deployment.VCSARootPass + "`' -x -D `"cn=Administrator,cn=Users,dc=lab-hcmny,dc=com`" -b `"cn=lab-hcmny.com,cn=Tenants,cn=IdentityManager,cn=services,dc=lab-hcmny,dc=com`" | grep vmwSTSDefaultIdentityProvider"

	$DefaultIdentitySource = $(Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput

	$versionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $script | Out-String

	$viVersion = $(Invoke-ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("") | Select-String -pattern $versionRegex

	Write-Output $viVersion

	if ($viVersion -match "6.7." -and $Deployment.DeployType -ne "infrastructure" -and $DefaultIdentitySource -ne $ADInfo.ADDomain) {
		# Write separator line to transcript.
		Write-SeparatorLine

		New-IdentitySourcevCenter67 $Deployment $ADInfo

		Write-SeparatorLine

		Add-SSOAdminGroups $Deployment $ADInfo $VIHandle
	} elseif ($viVersion -match "6.5." -and $pscDeployments -contains $Deployment.DeployType) {
		Write-SeparatorLine

		New-IdentitySourcevCenter65 $Deployment

		Write-SeparatorLine

		Add-SSOAdminGroups $Deployment $ADInfo $VIHandle
	}

	Write-SeparatorLine
}