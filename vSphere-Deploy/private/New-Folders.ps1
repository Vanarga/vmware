function New-Folders {
    <#
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
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Folders,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $VIHandle
    )

    Write-SeparatorLine

    ForEach ($folder in $Folders) {
        Write-Output -InputObject $folder.Name | Out-String
        ForEach ($dataCenter in get-datacenter -Server $VIHandle) {
            if ($folder.datacenter.Split(",") -match "all|$($dataCenter.name)") {
                $folderPath = $dataCenter | Get-Folder -name $folder.Location | Where-Object {$_.Parentid -notlike "*ha*"}
                Write-Output -InputObject $folderPath | Out-String
                New-Folder -Server $VIHandle -Name $folder.Name -Location $folderPath -Confirm:$false
            }
        }
    }
    Write-SeparatorLine
}