function Save-Yaml {
    <#
    .SYNOPSIS
		Save Object to yaml file.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-Yaml -InputObject < > -FilePath < >

        PS C:\> Save-Yaml

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Save-Yaml
    #>
	[cmdletbinding()]
    param (
		[Parameter(Mandatory=$true, Position=0)]
		$InputObject,
		[Parameter(Mandatory=$true, Position=1)]
		$FilePath
	)

	Remove-Null $InputObject

	$InputObject | ConvertTo-Hashtable | ConvertTo-Yaml | Set-Content -Path $FilePath
}