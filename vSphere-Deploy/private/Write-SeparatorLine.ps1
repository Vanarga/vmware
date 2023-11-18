function Write-SeparatorLine {
    <#
    .SYNOPSIS
        Print a dated line to standard output.

    .DESCRIPTION
        Print a dated line to standard output.

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
    $date = Get-Date
    Write-Output -InputObject "`n---------------------------- $date ----------------------------`r`n" | Out-String
}
