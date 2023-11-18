function Root-Path {
    <#
    .SYNOPSIS
        Return the rooted (absolute) path of a relative path string.

    .DESCRIPTION
        Return the rooted (absolute) path of a relative path string.

    .PARAMETER Path
        The mandatory string parameter Path is the path to be rooted.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Root-Path -Path <String>

        PS C:\> Root-Path

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Root-Path
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$Path
    )

    if (-not [System.IO.Path]::IsPathRooted($FilePath)) {
        # Resolve absolute path from relative path.
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    } else {
        return $Path
    }
}