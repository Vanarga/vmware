function Move-UserCerts {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Move-UserCerts

        PS C:\> Move-UserCerts

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Move-UserCerts
    #>
    [CmdletBinding ()]
    Param ()

    Get-ChildItem -Path $CertDir -Filter "*.crt" | ForEach-Object {
        $dir = $_.Basename
        if (-not(Test-Path -Path "$CertDir\$dir")) {
            New-Item -Path "$CertDir\$dir" -Type Directory
        }
        Move-Item -Path $_.FullName -Destination "$CertDir\$dir" -Force
    }
    Get-ChildItem -Path $CertDir -Filter "*.key" | ForEach-Object {
        $dir = $_.Basename
        Move-Item -Path $_.FullName -Destination "$CertDir\$dir" -Force
    }
}