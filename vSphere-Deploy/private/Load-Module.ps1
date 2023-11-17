function Load-Module {
    <#
    .SYNOPSIS
        Check is module is installed.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-ToJson -InputObject < > -FilePath < >

        PS C:\> Save-Json

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-25
        Version 1.0 - Verify-Module
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ModuleName
    )
    if (Get-Module -ListAvailable | Where-Object {$_.Name -match $ModuleName}) {
        Import-Module -Name $ModuleName -ErrorAction SilentlyContinue
    } else {
        if (Get-Command -Name Install-Module -ErrorAction SilentlyContinue) {
            Install-Module -Name $ModuleName -Confirm:$false
        } else {
            exit
        }
    }
}