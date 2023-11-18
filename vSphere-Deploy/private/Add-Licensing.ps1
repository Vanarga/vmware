function Add-Licensing {
    <#
    .SYNOPSIS
        This function adds all licenses and assigns the esxi licensing in bulk mode to the root.

    .DESCRIPTION
        This function adds all licenses and assigns the esxi licensing in bulk mode to the root.

    .PARAMETER Licenses
        The manadatory string array parameter Licenses holds all the lincense keys as strings.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Add-Licensing -Licenses <String[]>
                      -ViHandle <VI Session>

        PS C:\> Add-Licensing

    .NOTES
        http://vniklas.djungeln.se/2012/03/29/a-powercli-function-to-manage-vmware-vsphere-licenses/

        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Add-Licensing
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String[]]$Licenses,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-Output -InputObject $Licenses | Out-String
    $validLicenses = $Licenses | Where-Object {($_.psobject.properties.value | Measure-Object).Count -eq 4}
    ForEach ($license in $validLicenses) {
        $licenseManager = $null
        $addLicense = $null
        $licenseType = $null
        # Add License Key
        $licenseManager  = Get-View -Server $ViHandle ServiceInstance
        $addLicense  = Get-View -Server $ViHandle $licenseManager.Content.LicenseManager
        Write-Output -InputObject "Current Licenses in vCenter $($addLicense.Licenses.LicenseKey)" | Out-String
        if (-not($addLicense.Licenses.LicenseKey | Where-Object {$_ -eq $license.LicKey.trim()})) {
            Write-Output -InputObject "Adding $($license.LicKey) to vCenter" | Out-String
            $licenseType = $addLicense.AddLicense($($license.LicKey.trim()),$null)
        }

        if ($licenseType.Name -like "*vcenter*") {
            # Assign vCenter License
            $vcUUID = $licenseManager.Content.About.InstanceUuid
            $vcDisplayName = $licenseManager.Content.About.Name
            $licenseAssignManager = Get-View -Server $ViHandle $addLicense.licenseAssignmentManager
            if ($licenseAssignManager) {
                $licenseAssignManager.UpdateAssignedLicense($vcUUID, $license.LicKey, $vcDisplayName)
            }
        } else {
            # Assign Esxi License
            $licenseDataManager = Get-LicenseDataManager -Server $ViHandle
            for ($i=0;$i -lt $license.ApplyType.Split(",").count;$i++) {
               switch ($license.ApplyType.Split(",")[$i]) {
                 CL { $viContainer = Get-Cluster -Server $ViHandle -Name $license.ApplyTo.Split(",")[$i]; break}
                 DC { if ($license.ApplyTo.Split(",")[$i] -eq "Datacenters") {
                                    $viContainer = Get-Folder -Server $ViHandle -Name $license.ApplyTo.Split(",")[$i] -Type "Datacenter"
                                } else {
                                    $viContainer = Get-Datacenter -Server $ViHandle -Name $license.ApplyTo.Split(",")[$i]}; break
                                }
                 FO { $viContainer = Get-Folder -Server $ViHandle -Name $license.ApplyTo.Split(",")[$i] -Type "HostAndCluster"; break}
                 default { $viContainer = $null; break}
               }
               Write-Output -InputObject $viContainer | Out-String
               if ($viContainer) {
                   $licenseData = New-Object -TypeName VMware.VimAutomation.License.Types.LicenseData
                   $LicenseKeyEntry = New-Object -TypeName Vmware.VimAutomation.License.Types.LicenseKeyEntry
                   $LicenseKeyEntry.TypeId = "vmware-vsphere"
                   $LicenseKeyEntry.LicenseKey = $license.LicKey
                   $licenseData.LicenseKeys += $LicenseKeyEntry
                   $licenseDataManager.UpdateAssociatedLicenseData($viContainer.Uid, $licenseData)
                   $licenseDataManager.QueryAssociatedLicenseData($viContainer.Uid)
               }
            }
        }
    }
}