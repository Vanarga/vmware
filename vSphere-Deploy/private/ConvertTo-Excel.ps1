function ConvertTo-Excel {
    <#
    .SYNOPSIS
        Converts array of objects to range in Microsoft Excel worksheet.

    .DESCRIPTION
        Converts object to range in Microsoft Excel worksheet.

    .PARAMETER InputObject
        The mandatory PSObject array contains objects representing a row of data in Excel.

    .PARAMETER Worksheet
        The mandatory parameter Worksheet contains the Excel worksheet to add the data to.

    .PARAMETER SheetName
        The mandatory string parameter SheetName contains the name of the Excel worksheet.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-Excel -InputObject <PSObject>
                        -Worksheet <String>
                        -SheetName <String>

        PS C:\> ConvertTo-Excel

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-Excel
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $InputObject,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$Worksheet,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$SheetName
    )

    $myStack = New-Object -TypeName system.collections.stack

    $headers = $InputObject[0].PSObject.Properties.Name
    $values  = $InputObject | ForEach-Object {$_.psobject.properties.Value}

    if ($headers.Count -gt 1) {
        $values[($values.length - 1)..0] | ForEach-Object {$myStack.Push($_)}
        $headers[($headers.length - 1)..0] | ForEach-Object {$myStack.Push($_)}
    } else {
        $values | ForEach-Object {$myStack.Push($_)}
        $headers | ForEach-Object {$myStack.Push($_)}
    }

    $columns = $headers.Count
    $rows = $values.Count/$headers.count + 1
    $array = New-Object -TypeName 'object[,]' $rows, $columns

    for ($i=0;$i -lt $rows;$i++) {
        for ($j = 0; $j -lt $columns; $j++) {
            $array[$i,$j] = $myStack.Pop()
        }
    }

    $Worksheet.name = $SheetName
    if ($columns -le 26) {
        $ascii = [char]($columns + 96) + $rows
    } else {
        $ascii = "aa" + $rows
    }
    $range = $Worksheet.Range("a1",$ascii)
    $range.Value2 = $array
}