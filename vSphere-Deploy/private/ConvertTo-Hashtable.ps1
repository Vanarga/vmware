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
	[cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) {
			return $null
		}

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($Object in $InputObject) {
					ConvertTo-Hashtable $Object
				}
            )

            Write-Output -NoEnumerate $collection
        } elseif ($InputObject -is [psobject]) {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable $property.Value
            }
            $hash
		} else {
            $InputObject
        }
    }
}