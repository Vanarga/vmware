function Add-Licensing {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Licenses
	
    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Add-Licensing -Licenses < > -VIHandle < >

        PS C:\> Add-Licensing

    .NOTES
		http://vniklas.djungeln.se/2012/03/29/a-powercli-function-to-manage-vmware-vsphere-licenses/
		
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Add-Licensing
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Licenses,
		[Parameter(Mandatory=$true)]
		$VIHandle
	)

	Write-Output $Licenses | Out-String
	$validLicenses = $Licenses | Where-Object {($_.psobject.properties.value | Measure-Object).Count -eq 4}
	foreach ($license in $validLicenses) {
		$licenseManager	= $null
		$addLicense		= $null
		$licenseType	= $null
		# Add License Key
		$licenseManager  = Get-View -Server $VIHandle ServiceInstance
		$addLicense  = Get-View -Server $VIHandle $licenseManager.Content.LicenseManager
		Write-Output "Current Licenses in vCenter $($addLicense.Licenses.LicenseKey)" | Out-String
		if (-not($addLicense.Licenses.LicenseKey | Where-Object {$_ -eq $license.LicKey.trim()})) {
			Write-Output "Adding $($license.LicKey) to vCenter" | Out-String
			$licenseType = $addLicense.AddLicense($($license.LicKey.trim()),$null)
		}

		if ($licenseType.Name -like "*vcenter*") {
			# Assign vCenter License
			$vcUUID 		= $licenseManager.Content.About.InstanceUuid
			$vcDisplayName	= $licenseManager.Content.About.Name
			$licenseAssignManager	= Get-View -Server $VIHandle $addLicense.licenseAssignmentManager
			if ($licenseAssignManager) {
				$licenseAssignManager.UpdateAssignedLicense($vcUUID, $license.LicKey, $vcDisplayName)
			}
		} else {
			# Assign Esxi License
			$licenseDataManager = Get-LicenseDataManager -Server $VIHandle
			for ($i=0;$i -lt $license.ApplyType.Split(",").count;$i++) {
			   switch ($license.ApplyType.Split(",")[$i]) {
				 CL 		{ $viContainer = Get-Cluster -Server $VIHandle -Name $license.ApplyTo.Split(",")[$i]; break}
				 DC 		{ if ($license.ApplyTo.Split(",")[$i] -eq "Datacenters") {
					 				$viContainer = Get-Folder -Server $VIHandle -Name $license.ApplyTo.Split(",")[$i] -Type "Datacenter"
				 	 			} else {
									$viContainer = Get-Datacenter -Server $VIHandle -Name $license.ApplyTo.Split(",")[$i]}; break
								}
				 FO 		{ $viContainer = Get-Folder -Server $VIHandle -Name $license.ApplyTo.Split(",")[$i] -Type "HostAndCluster"; break}
				 default 	{ $viContainer = $null; break}
			   }
			   Write-Output $viContainer | Out-String
			   if ($viContainer) {
			   	   $licenseData					= New-Object VMware.VimAutomation.License.Types.LicenseData
			   	   $LicenseKeyEntry				= New-Object Vmware.VimAutomation.License.Types.LicenseKeyEntry
			       $LicenseKeyEntry.TypeId 		= "vmware-vsphere"
			       $LicenseKeyEntry.LicenseKey	= $license.LicKey
			       $licenseData.LicenseKeys 	+= $LicenseKeyEntry
			       $licenseDataManager.UpdateAssociatedLicenseData($viContainer.Uid, $licenseData)
			       $licenseDataManager.QueryAssociatedLicenseData($viContainer.Uid)
			   }
			}
		}
	}
}