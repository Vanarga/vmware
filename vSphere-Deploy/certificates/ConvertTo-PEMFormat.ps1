function ConvertTo-PEMFormat {
    <#
    .SYNOPSIS
		Create PEM file for supplied certificate

    .DESCRIPTION

    .PARAMETER SVCDir

	.PARAMETER CertFile

	.PARAMETER CerFile

	.PARAMETER CertDir

	.PARAMETER InstanceCertDir

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-PEMFormat -SVCDir < > -CertFile < > -CerFile < > -CertDir < > -InstanceCertDir < >

        PS C:\> ConvertTo-PEMFormat

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-PEMFormat
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$SVCDir,
		[Parameter(Mandatory=$true)]
		$CertFile,
		[Parameter(Mandatory=$true)]
		$CerFile,
		[Parameter(Mandatory=$true)]
		$CertDir,
		[Parameter(Mandatory=$true)]
		$InstanceCertDir
	)
	# Skip if we have pending cert requests
	if ($script:CertsWaitingForApproval) {
		return
	}
	if (Test-Path $CertDir\chain.cer) {
		$ChainCer = "$CertDir\chain.cer"
	} else {
		$ChainCer = "$CertDir\root64.cer"
	}

	if (-not(Test-Path $InstanceCertDir\$SVCDir\$CertFile)) {
		Write-Host "$InstanceCertDir\$SVCDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
	} else {
		$rui = Get-Content $InstanceCertDir\$SVCDir\$CertFile
		$chainCont = Get-Content $ChainCer -Encoding default
		$rui + $chainCont | Out-File  $InstanceCertDir\$SVCDir\$CerFile -Encoding default
		Write-Host "PEM file $InstanceCertDir\$SVCDir\$CerFile succesfully created" -ForegroundColor Yellow
	}
	Set-Location $CertDir
}