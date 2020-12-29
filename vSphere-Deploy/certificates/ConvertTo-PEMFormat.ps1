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
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $SVCDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CerFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $InstanceCertDir
    )
    # Skip if we have pending cert requests
    if ($script:CertsWaitingForApproval) {
        return
    }
    if (Test-Path -Path $CertDir\chain.cer) {
        $ChainCer = "$CertDir\chain.cer"
    } else {
        $ChainCer = "$CertDir\root64.cer"
    }

    if (-not(Test-Path -Path "$InstanceCertDir\$SVCDir\$CertFile")) {
        Write-Host -Object "$InstanceCertDir\$SVCDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
    } else {
        $rui = Get-Content -Path "$InstanceCertDir\$SVCDir\$CertFile"
        $chainCont = Get-Content $ChainCer -Encoding default
        $rui + $chainCont | Out-File -FilePath "$InstanceCertDir\$SVCDir\$CerFile" -Encoding default
        Write-Host -Object "PEM file $InstanceCertDir\$SVCDir\$CerFile succesfully created" -ForegroundColor Yellow
    }
    Set-Location -Path $CertDir
}