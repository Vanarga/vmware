function Copy-FileToServer {
    <#
    .SYNOPSIS
		Copy a file to a VM.

    .DESCRIPTION

    .PARAMETER Path
	
	.PARAMETER Hostname
	
	.PARAMETER Username
	
	.PARAMETER Password
	
	.PARAMETER VIHandle
	
	.PARAMETER Upload
	
    .EXAMPLE
        The example below shows the command line use with Parameters.

        Copy-FileToServer -Path < > -Hostname < > -Username < > -Password < > -VIHandle < > -Upload < >

        PS C:\> Copy-FileToServer

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Copy-FileToServer
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Path,
		[Parameter(Mandatory=$true)]
		$Hostname,
		[Parameter(Mandatory=$true)]
		$Username,
		[Parameter(Mandatory=$true)]
		$Password,
		[Parameter(Mandatory=$true)]
		$VIHandle,
		[Parameter(Mandatory=$true)]
		$Upload
	)

	Write-SeparatorLine

	for ($i=0; $i -le ($Path.count/2)-1;$i++) {
		Write-Host "Sources: `n"
		Write-Output $Path[$i*2] | Out-String
		Write-Host "Destinations: `n"
		Write-Output $Path[($i*2)+1] | Out-String
		if ($Upload) {
			Copy-VMGuestFile -VM $Hostname -LocalToGuest -Source $($Path[$i*2]) -Destination $($Path[($i*2)+1]) -guestuser $Username -GuestPassword $Password -Server $VIHandle -force
		} else {
			Copy-VMGuestFile -VM $Hostname -GuestToLocal -Source $($Path[$i*2]) -Destination $($Path[($i*2)+1]) -guestuser $Username -GuestPassword $Password -Server $VIHandle -force
		}
	}

	Write-SeparatorLine
}