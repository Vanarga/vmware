function Save-Json {
    <#
    .SYNOPSIS
        Save Object to json file.

    .DESCRIPTION
        Save Object to json file.

    .PARAMETER InputObject
        The mandatory PSObject array contains objects to be saved to the json file.

    .PARAMETER FilePath
        The mandatory string parameter FilePath is the path to the json file target.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-ToJson -InputObject <PSObject Array>
                    -FilePath <String>

        PS C:\> Save-Json

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Save-Json
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
            [string]$FilePath
    )

    Remove-Null -InputObject $InputObject

    $output = [ordered]@{}
    $output["vData.Type"] = $FilePath.split('\')[-1].split('.')[0]
    $output["Properties"] = $InputObject.Value
    $output | ConvertTo-Json | Set-Content -Path $FilePath
}