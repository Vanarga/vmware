function Import-JsonData {
    <#
    .SYNOPSIS
        Import the JSON data and return the values as a Hashtable.

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertPath < > -Deployment < > -VIHandle < >

        PS C:\> Import-HostRootCertificate

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2020-12-23
        Version 1.0 - Import-JsonData
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Path
    )

    # Declare an ordered hashtable.
    $ReturnSet = [Ordered]@{}

    $jsonFiles = (Get-ChildItem -Path $path).fullname

    ForEach ($file in $jsonFiles) {
        $data = Get-Content -Raw -Path $file | ConvertFrom-Json
        $ReturnSet[$data."vData.Type"] = $data.Properties
    }

    # Return the hashtable of custom objects.
    Return $ReturnSet
}