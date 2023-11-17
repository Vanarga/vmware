function ConvertTo-PEMFormat {
    <#
    .SYNOPSIS
        Convert the certificate to PEM format.

    .DESCRIPTION
        Convert the certificate to PEM format.

    .PARAMETER servicePath

    .PARAMETER certFile

    .PARAMETER cerFile

    .PARAMETER certPath

    .PARAMETER instanceCertPath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-PEMFormat -servicePath <string>
                            -certFile <string>
                            -cerFile <string>
                            -certPath <string>
                            -instanceCertPath <string>

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
        [string]$servicePath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$certFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$cerFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$certPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$instanceCertPath
    )
    # Skip if we have pending cert requests.
    if ($script:CertsWaitingForApproval) {
        return
    }
    if (Test-Path -Path $certPath\chain.cer) {
        $chainCer = "$certPath\chain.cer"
    } else {
        $chainCer = "$certPath\root64.cer"
    }
    # Check if the certificate file exists.
    if (-not(Test-Path -Path "$instanceCertPath\$servicePath\$certFile")) {
        Write-Host -Object "$instanceCertPath\$servicePath\$certFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
    } else {
        $rui = Get-Content -Path "$instanceCertPath\$servicePath\$certFile"
        $chainCont = Get-Content $chainCer -Encoding default
        $rui + $chainCont | Out-File -FilePath "$instanceCertPath\$servicePath\$cerFile" -Encoding default
        Write-Host -Object "PEM file $instanceCertPath\$servicePath\$cerFile succesfully created" -ForegroundColor Yellow
    }
    Set-Location -Path $certPath
}