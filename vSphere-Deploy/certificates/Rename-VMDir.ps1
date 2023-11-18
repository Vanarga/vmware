function Rename-VMDir {
    <#
    .SYNOPSIS
        Renames SSL certificate files to those used by VCSA.

    .DESCRIPTION

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the local path to the location of the replacement certificates.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Rename-VMDir -CertDir <String>

        PS C:\> Rename-VMDir

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Rename-VMDir
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertDir
    )
    # Renames SSL certificate files to those used by VCSA
    Rename-Item -Path "$CertDir\VMDir\VMDir.cer" -NewName "vmdircert.pem"
    Rename-Item -Path "$CertDir\VMDir\VMDir.priv" -NewName "vmdirkey.pem"
    Write-Host -Object "Certificate files renamed. Upload \VMDir\vmdircert.pem and \VMDir\vmdirkey.pem" -ForegroundColor Yellow
    Write-Host -Object "to VCSA at /usr/lib/vmware-dir/share/config" -ForegroundColor Yellow
}