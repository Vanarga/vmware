function Add-Null {
    <#
    .SYNOPSIS
        Replace "<null>" string values with $null in objects.

    .DESCRIPTION
        Replace "<null>" string values with $null in objects.

    .PARAMETER InputObject
        The manadatory psbject array parameter InputObject contains the values from the input data that the "<null>" qualifier needs to be added to.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Add-Null -InputObject <PSObject Array>

        PS C:\> Add-Null

    .NOTES
        http://vniklas.djungeln.se/2012/03/29/a-powercli-function-to-manage-vmware-vsphere-licenses/

        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Add-Null
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $InputObject
    )

    for ($i=0;$i -lt ($InputObject | Measure-Object).count;$i++) {
        $InputObject[$i].psobject.properties | Where-Object {if ($_.Value -match "null") {$_.Value = $null}}
    }
}