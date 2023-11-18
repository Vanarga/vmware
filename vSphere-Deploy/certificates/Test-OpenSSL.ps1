function Test-OpenSsl {
    <#
    .SYNOPSIS
        Check to see if OpenSSL is installed.

    .DESCRIPTION
        Check to see if OpenSSL is installed.

    .PARAMETER OpenSSL
        The mandatory string parameter OpenSsl is the path to the OpenSSL install folder.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Test-OpenSsl -OpenSSL <String>

        PS C:\> Test-OpenSsl

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Test-OpenSsl
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$OpenSSL
    )

    if (-not(Test-Path -Path $OpenSSL)) {
        Throw "Openssl required, unable to download, please install manually. Use latest OpenSSL 1.0.2."; Exit
    }
}