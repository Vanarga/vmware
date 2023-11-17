function Write-SeparatorLine {
    <#
    .SYNOPSIS
        Print a dated line to standard output.

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Write-SeparatorLine

        PS C:\> Write-SeparatorLine

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Write-SeparatorLine
    #>
    [CmdletBinding ()]
    Param ()
    $Date = Get-Date
    Write-Output -InputObject "`n---------------------------- $Date ----------------------------`r`n" | Out-String
}
