function ConvertTo-Excel {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER InputObject
	
    .PARAMETER WorkSheet
	
    .PARAMETER SheetName
	
    .PARAMETER Excelpath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-Excel -InputObject < > -WorkSheet < > -SheetName < > -Excelpath < >

        PS C:\> ConvertTo-Excel

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-Excel
    #>
	[cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
		$InputObject,
        [Parameter(Mandatory=$true)]
		$WorkSheet,
		[Parameter(Mandatory=$true)]
		$SheetName,
		[Parameter(Mandatory=$true)]
		$Excelpath
	)

	$myStack = new-object system.collections.stack

	$headers = $InputObject[0].PSObject.Properties.Name
	$values  = $InputObject | ForEach-Object {$_.psobject.properties.Value}

	if ($headers.count -gt 1) {
		$values[($values.length - 1)..0] | ForEach-Object {$myStack.Push($_)}
		$headers[($headers.length - 1)..0] | ForEach-Object {$myStack.Push($_)}
	} else {
		$values	 | ForEach-Object {$myStack.Push($_)}
		$headers | ForEach-Object {$myStack.Push($_)}
	}

	$columns = $headers.count
	$rows = $values.count/$headers.count + 1
	$array = New-Object 'object[,]' $rows, $columns

	for ($i=0;$i -lt $rows;$i++) {
		for ($j = 0; $j -lt $columns; $j++) {
			$array[$i,$j] = $myStack.Pop()
		}
	}

	$WorkSheet.name = $SheetName
	if ($columns -le 26) {
		$ascii = [char]($columns + 96) + $rows
	} else {
		$ascii = "aa" + $rows
	}
	$range = $WorkSheet.Range("a1",$ascii)
	$range.Value2 = $array
}