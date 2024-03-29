function ConvertTo-PEMFormat {
    <#
    .SYNOPSIS
        Convert the certificate to PEM format.

    .DESCRIPTION
        Convert the certificate to PEM format.

    .PARAMETER SvcDir
        The mandatory string parameter SvcDir is the vmware service directory name and is used for the subfolder to place the certficates in.

    .PARAMETER CertFile
        The mandatory string parameter CertFile is the certificate filename.

    .PARAMETER CerFile
        The mandatory string parameter CerFile is the CER certificate filename.

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the certificate for a specific directory service.

    .PARAMETER InstanceCertDir
        The mandatory string parameter InstanceCertDir is the local certificate folder for the node instance being deployed.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-PEMFormat -ServicePath <string>
                            -CertFile <string>
                            -CerFile <string>
                            -CertDir <string>
                            -InstanceCertDir <string>

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
            [string]$SvcDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CerFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$InstanceCertDir
    )
    # Skip if we have pending cert requests.
    if ($script:CertsWaitingForApproval) {
        return
    }
    if (Test-Path -Path $CertDir\chain.cer) {
        $chainCer = "$CertDir\chain.cer"
    } else {
        $chainCer = "$CertDir\root64.cer"
    }
    # Check if the certificate file exists.
    if (-not(Test-Path -Path "$InstanceCertDir\$SvcDir\$CertFile")) {
        Write-Host -Object "$InstanceCertDir\$SvcDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
    } else {
        $rui = Get-Content -Path "$InstanceCertDir\$SvcDir\$CertFile"
        $chainCont = Get-Content $chainCer -Encoding default
        $rui + $chainCont | Out-File -FilePath "$InstanceCertDir\$SvcDir\$CerFile" -Encoding default
        Write-Host -Object "PEM file $InstanceCertDir\$SvcDir\$CerFile succesfully created" -ForegroundColor Yellow
    }
    Set-Location -Path $CertDir
}