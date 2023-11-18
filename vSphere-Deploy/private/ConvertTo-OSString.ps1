function ConvertTo-OsString {
    <#
    .SYNOPSIS
        Convert OS Customization Object to String needed to run the command.

    .DESCRIPTION
        Convert OS Customization Object to String needed to run the command.

    .PARAMETER InputObject
        The mandatory PSObject parameter InputObject holds the values that need to be formatted.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        ConvertTo-OsString -InputObject <PSObject>

        PS C:\> ConvertTo-OsString

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - ConvertTo-OSString
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $InputObject
    )

    $os = "New-OSCustomizationSpec "
    ForEach ($i in $InputObject.PSObject.Properties) {
        if ($i.Value) {
            $os = $os.insert($os.length,"-" + $i.Name + ' "' + $i.Value + '" ')}
    }

    $os = $os -replace " `"true`"", ""
    $os = $os -replace " -ChangeSid `"false`"",""
    $os = $os -replace " -DeleteAccounts `"false`"",""
    $os = $os -replace " -vCenter "," -Server "

    Write-Output -InputObject $os | Out-String

    Invoke-Expression $os
}