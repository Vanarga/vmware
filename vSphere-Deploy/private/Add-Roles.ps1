function Add-Roles {
    <#
    .SYNOPSIS
        Create Roles

    .DESCRIPTION

    .PARAMETER Roles

    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Add-Roles -Roles < > -VIHandle < >

        PS C:\> Add-Roles

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Add-Roles
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Roles,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $VIHandle
    )

    Write-SeparatorLine

    $existingRoles = Get-ViRole -Server $VIHandle | Select-Object Name

    $names = $($Roles | Select-Object Name -Unique) | Where-Object {$existingRoles.name -notcontains $_.name}

    Write-Output -InputObject $names | Out-String

    ForEach ($name in $names) {
        $vPrivilege = $Roles | Where-Object {$_.Name -like $name.Name} | Select-Object Privilege

        Write-Output -InputObject $vPrivilege | Out-String

        New-VIRole -Server $VIHandle -Name $name.Name -Privilege (Get-VIPrivilege -Server $VIHandle | Where-Object {$vPrivilege.Privilege -like $_.id})
    }

    Write-SeparatorLine
}