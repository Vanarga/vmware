function New-Folders {
    <#
    .SYNOPSIS
        Create Folders on the vCenter.

    .DESCRIPTION
        Create Folders on the vCenter.

    .PARAMETER Folders
        The mandatory string array parameter Folders contains all the folders that need to be created and informaiton about their heirarchy.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-Folders -Folders <String[]>
                    -ViHandle <VI Session>

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
            [string[]]$Folders,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-SeparatorLine

    ForEach ($folder in $Folders) {
        Write-Output -InputObject $folder.Name | Out-String
        ForEach ($dataCenter in Get-Datacenter -Server $ViHandle) {
            if ($folder.datacenter.Split(",") -match "all|$($dataCenter.name)") {
                $folderPath = $dataCenter | Get-Folder -name $folder.Location | Where-Object {$_.Parentid -notlike "*ha*"}
                Write-Output -InputObject $folderPath | Out-String
                New-Folder -Server $ViHandle -Name $folder.Name -Location $folderPath -Confirm:$false
            }
        }
    }
    Write-SeparatorLine
}