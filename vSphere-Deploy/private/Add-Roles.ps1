function Add-Roles {
    <#
    .SYNOPSIS
        Create vSphere Roles.

    .DESCRIPTION
        Create vSphere Roles.

    .PARAMETER Roles
        The mandatory string array Roles, holds all the vSphere custom roles that will be added to the vCenter.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Add-Roles -Roles <String[]>
                  -ViHandle <VI Session>

        PS C:\> Add-Roles

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Add-Roles
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$Roles,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-SeparatorLine

    $existingRoles = Get-ViRole -Server $ViHandle | Select-Object Name

    $names = $($Roles | Select-Object Name -Unique) | Where-Object {$existingRoles.name -notcontains $_.name}

    Write-Output -InputObject $names | Out-String

    ForEach ($name in $names) {
        $vPrivilege = $Roles | Where-Object {$_.Name -like $name.Name} | Select-Object Privilege

        Write-Output -InputObject $vPrivilege | Out-String

        New-VIRole -Server $ViHandle -Name $name.Name -Privilege (Get-VIPrivilege -Server $ViHandle | Where-Object {$vPrivilege.Privilege -like $_.id})
    }

    Write-SeparatorLine
}