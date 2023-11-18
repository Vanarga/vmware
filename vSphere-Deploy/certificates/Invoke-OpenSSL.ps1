function Invoke-OpenSsl {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER OpenSslArgs

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-OpenSSL -OpenSslArgs <String[]>

        PS C:\> Invoke-OpenSSL

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-OpenSSL
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$OpenSslArgs
    )

    $OpenSslInfo = $null
    $processDiag = $null
    $OpenSslInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $OpenSslInfo.FileName = $OpenSSL
    $OpenSslInfo.RedirectStandardError = $true
    $OpenSslInfo.RedirectStandardOutput = $true
    $OpenSslInfo.UseShellExecute = $false
    $OpenSslInfo.Arguments = $OpenSslArgs
    $processDiag = New-Object -TypeName System.Diagnostics.Process
    $processDiag.StartInfo = $OpenSslInfo
    $processDiag.Start() | Out-Null
    $processDiag.WaitForExit()
    $stdOut = $processDiag.StandardOutput.ReadToEnd()
    $stdErr = $processDiag.StandardError.ReadToEnd()
    Write-Host -Object "stdout: $stdOut"
    Write-Host -Object "stderr: $stdErr"
    Write-Host -Object "exit code: " + $processDiag.ExitCode
    return $stdOut
}