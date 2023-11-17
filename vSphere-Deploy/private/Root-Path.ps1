function Root-Path {
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
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Path
    )

    if (-not [System.IO.Path]::IsPathRooted($FilePath)) {
        # Resolve absolute path from relative path.
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    } else {
        return $Path
    }
}