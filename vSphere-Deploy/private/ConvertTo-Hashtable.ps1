function ConvertTo-Hashtable {
    <#
    .SYNOPSIS
        Convert PS Object to Hashtable.

    .DESCRIPTION

    .PARAMETER InputObject

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-Hashtable -InputObject < >

        PS C:\> ConvertTo-Hashtable

    .NOTES
        Dave Wyatt - https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable

        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-Hashtable
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return $null
        }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                ForEach ($Object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $Object
                }
            )

            Write-Output -InputObject $collection -NoEnumerate
        } elseif ($InputObject -is [psobject]) {
            $hash = @{}
            ForEach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        } else {
            $InputObject
        }
    }
}