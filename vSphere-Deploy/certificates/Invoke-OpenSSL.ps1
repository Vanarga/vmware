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
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$OpenSSLArgs
	)

	$openSSLInfo = $null
	$processDiag = $null
	$openSSLInfo = New-Object System.Diagnostics.ProcessStartInfo
	$openSSLInfo.FileName = $OpenSSL
	$openSSLInfo.RedirectStandardError = $true
	$openSSLInfo.RedirectStandardOutput = $true
	$openSSLInfo.UseShellExecute = $false
	$openSSLInfo.Arguments = $OpenSSLArgs
	$processDiag = New-Object System.Diagnostics.Process
	$processDiag.StartInfo = $openSSLInfo
	$processDiag.Start() | Out-Null
	$processDiag.WaitForExit()
	$stdOut = $processDiag.StandardOutput.ReadToEnd()
	$stdErr = $processDiag.StandardError.ReadToEnd()
	Write-Host "stdout: $stdOut"
	Write-Host "stderr: $stdErr"
	Write-Host "exit code: " + $processDiag.ExitCode
	return $stdOut
}