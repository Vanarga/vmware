function Load-Module {
    <#
    .SYNOPSIS
        Check is module is installed, load it if it is, and install and load it, if it is not.

    .DESCRIPTION
        Check is module is installed, load it if it is, and install and load it, if it is not.

    .PARAMETER ModuleName
        The mandatory string parameter ModuleName is the name of the module to load/install.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Load-Module -ModuleName <String>

        PS C:\> Load-Module

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-25
        Version 1.0 - Load-Module
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$ModuleName
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