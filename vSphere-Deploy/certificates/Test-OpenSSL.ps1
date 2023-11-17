function Test-OpenSSL {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER OpenSSL

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Test-OpenSSL -OpenSSL < >

        PS C:\> Test-OpenSSL

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Test-OpenSSL
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $openSSL
    )

    if (-not(Test-Path -Path $openSSL)) {
        Throw "Openssl required, unable to download, please install manually. Use latest OpenSSL 1.0.2."; Exit
    }
}