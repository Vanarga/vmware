function Remove-Null {
    <#
    .SYNOPSIS
		Replace $null values with "<null>" string in objects.

    .DESCRIPTION

    .PARAMETER InputObject

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Remove-Null -InputObject < >

        PS C:\> Remove-Null

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Remove-Null
    #>
	[cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	$InputObject | ForEach-Object {$_.psobject.properties | Where-Object {-not $_.value -and $_.TypeNameOfValue -ne "System.Boolean"} | ForEach-Object {$_.value = "<null>"}}
}