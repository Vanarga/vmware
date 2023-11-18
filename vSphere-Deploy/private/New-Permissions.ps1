function New-Permissions {
    <#
    .SYNOPSIS
        Set Permissions in vCenter.

    .DESCRIPTION
        Set Permissions in vCenter.

    .PARAMETER VPermissions
        The mandatory string array parameter VPermissions contains all the permissions to be applied to the vCenter.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-Permissions -VPermissions <String[]>
                        -ViHandle <VI Session>

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
            [string[]]$VPermissions,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-SeparatorLine

    Write-Output -InputObject "Permissions:" $VPermissions  | Out-String

    ForEach ($permission in $VPermissions) {
        $entity = Get-Inventory -Name $permission.Entity | Where-Object {$_.Id -match $permission.Location}
        if ($permission.Group) {
            $principal = Get-VIAccount -Group -Name $permission.Principal -Server $ViHandle
        } else {
            $principal = Get-VIAccount -Name $permission.Principal -Server $ViHandle
        }

        Write-Output -InputObject "New-VIPermission -Server $ViHandle -Entity $entity -Principal $principal -Role $($permission.Role) -Propagate $([System.Convert]::ToBoolean($permission.Propagate))" | Out-String

        New-VIPermission -Server $ViHandle -Entity $entity -Principal $principal -Role $permission.Role -Propagate $([System.Convert]::ToBoolean($permission.Propagate))

    }
    Write-SeparatorLine
}