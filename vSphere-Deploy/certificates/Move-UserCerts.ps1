function Move-UserCerts {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Move-UserCerts

        PS C:\> Move-UserCerts

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Move-UserCerts
    #>
	[cmdletbinding()]
	
	Get-ChildItem -Path $CertDir -filter "*.crt" | ForEach-Object {
		$dir = $_.Basename
		if (-not(Test-Path $CertDir\$dir)) {
			New-Item $CertDir\$dir -Type Directory
		}
		Move-Item -Path $_.FullName -Destination $CertDir\$dir -Force
	}
	Get-ChildItem -Path $CertDir -filter "*.key" | ForEach-Object {
		$dir = $_.Basename
		Move-Item -Path $_.FullName -Destination $CertDir\$dir -Force
	}
}