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
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $VPermissions,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $VIHandle
    )

    Write-SeparatorLine

    Write-Output -InputObject "Permissions:" $VPermissions  | Out-String

    ForEach ($permission in $VPermissions) {
        $entity = Get-Inventory -Name $permission.Entity | Where-Object {$_.Id -match $permission.Location}
        if ($permission.Group) {
            $principal = Get-VIAccount -Group -Name $permission.Principal -Server $VIHandle
        } else {
            $principal = Get-VIAccount -Name $permission.Principal -Server $VIHandle
        }

        Write-Output -InputObject "New-VIPermission -Server $VIHandle -Entity $entity -Principal $principal -Role $($permission.Role) -Propagate $([System.Convert]::ToBoolean($permission.Propagate))" | Out-String

        New-VIPermission -Server $VIHandle -Entity $entity -Principal $principal -Role $permission.Role -Propagate $([System.Convert]::ToBoolean($permission.Propagate))

    }
    Write-SeparatorLine
}