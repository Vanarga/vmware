function Save-Json {
    <#
    .SYNOPSIS
        Save Object to json file.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-ToJson -InputObject < > -FilePath < >

        PS C:\> Save-Json

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Save-Json
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $InputObject,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $FilePath
    )

    Remove-Null -InputObject $InputObject

    $output = [ordered]@{}
    $output["vData.Type"] = $FilePath.split('\')[-1].split('.')[0]
    $output["Properties"] = $InputObject.Value
    $output | ConvertTo-Json | Set-Content -Path $FilePath
}