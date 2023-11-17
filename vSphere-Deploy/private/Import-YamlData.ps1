function Import-YamlData {
    <#
    .SYNOPSIS
        Import the JSON data and return the values as a Hashtable.

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertDir < > -Deployment < > -ViHandle < >

        PS C:\> Import-HostRootCertificate

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2020-12-23
        Version 1.0 - Import-YamlData
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Path
    )

    # Declare an ordered hashtable.
    $returnSet = [Ordered]@{}

    $yamlFiles = (Get-ChildItem -Path $path).FullName

    ForEach ($file in $yamlFiles) {
        $data = [pscustomobject](Get-Content -Raw -Path $file | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
        $returnSet[$data."vData.Type"] = $data.Properties
    }
    for ($i=0;$i -lt ($ReturnSet.vlans | Measure-Object).count;$i++) {
        $returnSet.vlans[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
    }
    # Return the hashtable of custom objects.
    Return $returnSet
}