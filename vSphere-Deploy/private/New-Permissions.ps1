function New-Permissions {
    <#
    .SYNOPSIS
		Set Permissions

    .DESCRIPTION

    .PARAMETER VPermissions

    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-Permissions -VPermissions < > -VIHandle < >

        PS C:\> New-Permissions 

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-Permissions
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$VPermissions,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	Write-SeparatorLine

	Write-Output  "Permissions:" $VPermissions  | Out-String

	foreach ($permission in $VPermissions) {
		$entity = Get-Inventory -Name $permission.Entity | Where-Object {$_.Id -match $permission.Location}
		if ($permission.Group) {
			$principal = Get-VIAccount -Group -Name $permission.Principal -Server $VIHandle
		} else {
			$principal = Get-VIAccount -Name $permission.Principal -Server $VIHandle
		}

		Write-Output "New-VIPermission -Server $VIHandle -Entity $entity -Principal $principal -Role $($permission.Role) -Propagate $([System.Convert]::ToBoolean($permission.Propagate))" | Out-String

		New-VIPermission -Server $VIHandle -Entity $entity -Principal $principal -Role $permission.Role -Propagate $([System.Convert]::ToBoolean($permission.Propagate))

	}

	Write-SeparatorLine
}