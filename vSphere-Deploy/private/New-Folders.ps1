function New-Folders {
    .SYNOPSIS
		Create Folders

    .DESCRIPTION

    .PARAMETER Folders
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-Folders -Folders < > -VIHandle < >

        PS C:\> New-Folders

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-Folders
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Folders,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

    Write-SeparatorLine

	foreach ($folder in $Folders) {
		Write-Output $folder.Name | Out-String
		foreach ($dataCenter in get-datacenter -Server $VIHandle) {
			if ($folder.datacenter.Split(",") -match "all|$($dataCenter.name)") {
				$folderPath = $dataCenter | Get-Folder -name $folder.Location | Where-Object {$_.Parentid -notlike "*ha*"}
				Write-Output $folderPath | Out-String
				New-Folder -Server $VIHandle -Name $folder.Name -Location $folderPath -Confirm:$false
			}
		}
	}

	Write-SeparatorLine
}