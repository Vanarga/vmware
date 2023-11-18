function Import-JsonData {
    <#
    .SYNOPSIS
        Import the JSON data and return the values as a Hashtable.

    .DESCRIPTION
        Import the JSON data and return the values as a Hashtable.

    .PARAMETER Path
        The mandatory string parameter Path is the location of the json files.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-JsonData -Path <String>

        PS C:\> Import-JsonData

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
            [string]$Path
    )

    # Declare an ordered hashtable.
    $returnSet = [Ordered]@{}

    $jsonFiles = (Get-ChildItem -Path $path).fullname

    ForEach ($file in $jsonFiles) {
        $data = Get-Content -Raw -Path $file | ConvertFrom-Json
        $returnSet[$data."vData.Type"] = $data.Properties
    }

    # Return the hashtable of custom objects.
    Return $returnSet
}