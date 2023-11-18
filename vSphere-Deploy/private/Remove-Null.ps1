function Remove-Null {
    <#
    .SYNOPSIS
        Replace $null values with "<null>" string in objects.

    .DESCRIPTION
        Replace $null values with "<null>" string in objects.

    .PARAMETER InputObject
        The mandatory PSObject array contains objects to have $null replaced with <null>.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Remove-Null -InputObject <PSObject Array>

        PS C:\> Remove-Null

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Remove-Null
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $InputObject
    )

    $InputObject | ForEach-Object {
        $_.psobject.properties | Where-Object {-not $_.value -and $_.TypeNameOfValue -ne "System.Boolean"} | ForEach-Object {
            $_.value = "<null>"
        }
    }
}