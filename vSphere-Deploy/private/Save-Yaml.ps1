function Save-Yaml {
    <#
    .SYNOPSIS
        Save Object to yaml file.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-Yaml -InputObject < > -FilePath < >

        PS C:\> Save-Yaml

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Save-Yaml
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
            $FilePath
    )

    Remove-Null -InputObject $InputObject
    $output = [ordered]@{}
    $output["vData.Type"] = $FilePath.split('\')[-1].split('.')[0]
    $output["Properties"] = $InputObject.Value
    $output | ConvertTo-Yaml | Set-Content -Path $FilePath
}