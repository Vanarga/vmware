function ConvertTo-OSString {
    <#
    .SYNOPSIS
		Convert OS Customization Object to Stirng needed to run the command.

    .DESCRIPTION

    .PARAMETER InputObject
	
    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-OSString -InputObject < >

        PS C:\> ConvertTo-OSString

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-OSString
    #>
	[cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
	)

	$os = "New-OSCustomizationSpec "
	foreach ($i in $InputObject.PSObject.Properties) {
		if ($i.Value) {
			$os = $os.insert($os.length,"-" + $i.Name + ' "' + $i.Value + '" ')}
	}

	$os = $os -replace " `"true`"", ""
	$os = $os -replace " -ChangeSid `"false`"",""
	$os = $os -replace " -DeleteAccounts `"false`"",""
	$os = $os -replace " -vCenter "," -Server "

	Write-Output $os | Out-String

	Invoke-Expression $os
}