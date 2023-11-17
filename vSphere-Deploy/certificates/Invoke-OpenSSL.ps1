function Invoke-OpenSSL {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER OpenSSLArgs

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-OpenSSL -OpenSSLArgs < >

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
        $OpenSSLArgs
    )

    $OpenSSLInfo = $null
    $processDiag = $null
    $OpenSSLInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $OpenSSLInfo.FileName = $OpenSSL
    $OpenSSLInfo.RedirectStandardError = $true
    $OpenSSLInfo.RedirectStandardOutput = $true
    $OpenSSLInfo.UseShellExecute = $false
    $OpenSSLInfo.Arguments = $OpenSSLArgs
    $processDiag = New-Object -TypeName System.Diagnostics.Process
    $processDiag.StartInfo = $OpenSSLInfo
    $processDiag.Start() | Out-Null
    $processDiag.WaitForExit()
    $stdOut = $processDiag.StandardOutput.ReadToEnd()
    $stdErr = $processDiag.StandardError.ReadToEnd()
    Write-Host -Object "stdout: $stdOut"
    Write-Host -Object "stderr: $stdErr"
    Write-Host -Object "exit code: " + $processDiag.ExitCode
    return $stdOut
}