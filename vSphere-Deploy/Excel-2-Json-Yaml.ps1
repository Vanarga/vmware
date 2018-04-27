# ---------------------  Load Parameters from Excel ------------------------------

# https://kevinmarquette.github.io/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/#creating-a-pscustomobject
import-module powershell-yaml
cls

function removenull
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	$InputObject | %{$_.psobject.properties | ?{!$_.value -and $_.TypeNameOfValue -ne "System.Boolean"} | %{$_.value = "<null>"}}
}

function ConvertPSObjectToHashtable
# Dave Wyatt - https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}


If (!(Test-Path -Path "$PSScriptRoot\Json")) {New-Item "$PSScriptRoot\Json" -Type Directory}
If (!(Test-Path -Path "$PSScriptRoot\Yaml")) {New-Item "$PSScriptRoot\Yaml" -Type Directory}

# Password Scrub array for redacting passwords from Transcript.
$scrub = @()

# Global variables
$ExcelFilePath = "$PSScriptRoot\vsphere-configs.xlsx"

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
$workBook 	= $objExcel.Workbooks.Open($ExcelFilePath)

# get ad info
$workSheet	= $WorkBook.sheets.item("adinfo")
$lastrow	= $worksheet.Range("A:A").count
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data	  = $Worksheet.Range("A2","F$rows").Value().split("`n")

	$s_adinfo = [PSCustomObject]@{
		ADDomain        = $data[0]
		ADJoinUser		= $data[1]
		ADJoinPass		= $data[2]		
		ADvCenterAdmins	= $data[3]
		ADvmcamUser		= $data[4]		
		ADvmcamPass		= $data[5]
	}
	
	$scrub += $s_adinfo.ADJoinPass
	$scrub += $s_adinfo.ADvmcamPass

	echo $s_adinfo | Out-String

	removenull $s_adinfo

    $s_adinfo | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\ad-info.json"

	$s_adinfo | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\ad-info.yml"
}



# get plugins
$workSheet	= $WorkBook.sheets.item("plugins")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data 		= $Worksheet.Range("A2","F$rows").Value()
	$s_plugins = @()
	for ($i=1;$i -lt $rows;$i++){
		$s_plugin  = [PSCustomObject]@{
			Config 			= $([System.Convert]::ToBoolean($($data[$i,1])))
			vCenter 		= $data[$i,2]
			SourceDir 		= $data[$i,3]
			DestDir 		= $data[$i,4]
			SourceFiles 	= $data[$i,5]
			Command 		= $data[$i,6]
		}
		$s_plugins += $s_plugin
	}
	echo $s_plugins | Out-String

    $s_plugins | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\plugins.json"
	
    removenull $s_plugins
	
    $s_plugins | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\plugins.yml"
}



# get autodeploy rules
$workSheet	= $WorkBook.sheets.item("autodeploy")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data	  = $Worksheet.Range("A2","K$rows").Value()
	$s_arules = @()
	for ($i=1;$i -lt $rows;$i++){
		$s_arule  = [PSCustomObject]@{
			vCenter					= $data[$i,1]
			RuleName				= $data[$i,2]			
			ProfileImport			= $data[$i,3]		
			ProfileName				= $data[$i,4]
			ProfileRootPassword     = $data[$i,5]		
			ProfileAnnotation		= $data[$i,6]
			Datacenter				= $data[$i,7]
			Cluster					= $data[$i,8]
			SoftwareDepot			= $data[$i,9]
			Pattern					= $data[$i,10]
			Activate				= $data[$i,11]
		}
		$s_arules += $s_arule

		$scrub += $s_arule.ProfileRootPassword
	}
	echo $s_arules | Out-String

    $s_arules | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\autodeploy-rules.json"

    removenull $s_arules

    $s_arules | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\autodeploy-rules.yml"
}



# get certificate info
$workSheet	= $WorkBook.sheets.item("certs")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("B:B"),"<>")
$data = $null

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","R$rows").Value().split("`n")
	$s_Certinfo  = [PSCustomObject]@{
		openssldir		= $data[0]
		RootCA			= $data[1]
		SubCA1			= $data[2]		
		SubCA2			= $data[3]
		CompanyName     = $data[4]
		OrgName		    = $data[5]
		OrgUnit			= $data[6]
		State			= $data[7]
		Locality		= $data[8]
		Country			= $data[9]
		Email			= $data[10]
		CADownload	    = $data[11]
		IssuingCA		= $data[12]
		V6Template	    = $data[13]
		SubTemplate	   	= $data[14]
		RootRenewal		= $data[15]
		SubRenewal1		= $data[16]
		SubRenewal2		= $data[17]
	}
	
	if ($s_Certinfo.SubCA1 -eq "null") {$s_Certinfo.SubCA1 = $null}
	if ($s_Certinfo.SubCA2 -eq "null") {$s_Certinfo.SubCA2 = $null}

	echo $s_Certinfo | Out-String

    $s_Certinfo | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\cert-info.json"

    removenull $s_Certinfo

    $s_Certinfo | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\cert-info.yml"
}



# get clusters
$workSheet	= $WorkBook.sheets.item("clusters")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data 		= $Worksheet.Range("A2","C$rows").Value()
	$s_clusters = @()
	for ($i=1;$i -lt $rows;$i++){
		$s_cluster  = [PSCustomObject]@{
			ClusterName     = $data[$i,1]
			Datacenter		= $data[$i,2]
			vCenter			= $data[$i,3]
		}
		$s_clusters += $s_cluster
	}
	echo $s_clusters | Out-String

    $s_clusters | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\cluster-info.json"

    removenull $s_clusters

    $s_clusters | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\cluster-info.yml"
}



# get folders
$workSheet	= $WorkBook.sheets.item("folders")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","F$rows").Value()
	$s_folders	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_folder  = [PSCustomObject]@{
			Name		= $data[$i,1]
			Location	= $data[$i,2]
			Type		= $data[$i,3]
			Datacenter	= $data[$i,4]
			vCenter		= $data[$i,5]
			Tier		= $data[$i,6]
		}
		$s_folders += $s_folder
	}
$S_folders = $s_folders | Sort-Object -Property Tier, Name
echo $s_folders | Out-String

    $s_folders | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\folders.json"

    removenull $s_folders

    $s_folders | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\folders.yml"
}



# get Permissions
$workSheet	= $WorkBook.sheets.item("permissions")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data			= $Worksheet.Range("A2","F$rows").Value()
	$s_Permissions	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_Permission  = [PSCustomObject]@{
			Entity		= $data[$i,1]
			Principal	= $data[$i,2]	
			Group		= $data[$i,3]
			Propagate	= $data[$i,4]	
			Role		= $data[$i,5]
			vCenter		= $data[$i,6]
		}
		$s_Permissions += $s_Permission
	}
	echo $s_Permissions | Out-String

	$s_Permissions | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\permissions.json"

	removenull $s_Permissions

	$s_Permissions | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\permissions.yml"
}



# get OS Customizations
$workSheet	= $WorkBook.sheets.item("OS")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data				= $Worksheet.Range("A2","Y$rows").Value()
	$s_Customizations	= @()
	$s_CustomPasswords  = @()
	for ($i=1;$i -lt $rows;$i++){
		$s_Customization = New-Object System.Object
		$s_Customization = ""
		if ($data[$i,1]) {$s_Customization = $s_Customization.insert($s_Customization.length," -OSType `"$($data[$i,1])`"")}
		if ($data[$i,2]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Server `"$($data[$i,2])`"")}
		if ($data[$i,3]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Name `"$($data[$i,3])`"")}
		if ($data[$i,4]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Type $($data[$i,4])")}
		if ($data[$i,5]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DnsServer `"$($data[$i,5])`"")}
		if ($data[$i,6]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DnsSuffix `"$($data[$i,6])`"")}
		if ($data[$i,7]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Domain `"$($data[$i,7])`"")}
		if ($data[$i,8]) {$s_Customization = $s_Customization.insert($s_Customization.length," -NamingScheme `"$($data[$i,8])`"")}
		if ($data[$i,9]) {$s_Customization = $s_Customization.insert($s_Customization.length," -NamingPrefix `"$($data[$i,9])`"")}
		if ($data[$i,10]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Description `"$($data[$i,10])`"")}
		if ($data[$i,11]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Spec `"$($data[$i,11])`"")}
		if ($data[$i,12]) {$s_Customization = $s_Customization.insert($s_Customization.length," -FullName `"$($data[$i,12])`"")}
		if ($data[$i,13]) {$s_Customization = $s_Customization.insert($s_Customization.length," -OrgName `"$($data[$i,13])`"")}
		if ($data[$i,14] -like "true") {$s_Customization = $s_Customization.insert($s_Customization.length," -ChangeSid")}
		if ($data[$i,15] -like "true") {$s_Customization = $s_Customization.insert($s_Customization.length," -DeleteAccounts")}
		if ($data[$i,16]) {$s_Customization = $s_Customization.insert($s_Customization.length," -GuiRunOnce `"$($data[$i,16])`"")}
		if ($data[$i,17]) {$s_Customization = $s_Customization.insert($s_Customization.length," -AdminPassword `"$($data[$i,17])`"")}
		if ($data[$i,18]) {$s_Customization = $s_Customization.insert($s_Customization.length," -TimeZone `"$($data[$i,18])`"")}
		if ($data[$i,19]) {$s_Customization = $s_Customization.insert($s_Customization.length," -AutoLogonCount $($data[$i,19])")}
		if ($data[$i,20]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Workgroup `"$($data[$i,20])`"")}
		if ($data[$i,21]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DomainUsername `"$($data[$i,21])`"")}
		if ($data[$i,22]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DomainPassword `"$($data[$i,22])`"")}
		if ($data[$i,23]) {$s_Customization = $s_Customization.insert($s_Customization.length," -ProductKey `"$($data[$i,23])`"")}
		if ($data[$i,24]) {$s_Customization = $s_Customization.insert($s_Customization.length," -LicenseMode $($data[$i,24])")}
		if ($data[$i,25]) {$s_Customization = $s_Customization.insert($s_Customization.length," -LicenseMaxConnections $($data[$i,25])")}
		$s_Customizations += $s_Customization.insert(0,"New-OSCustomizationSpec")

		$scrub += $data[$i,17]
		$scrub += $data[$i,22]
	}
	echo $s_Customizations | Out-String

    $s_Customizations | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\os-customizations.json"

	removenull $s_Customizations

    $s_Customizations | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\os-customizations.yml"
}



# get Deployments
$s_Deployments	= @()
$dataqueue		= New-Object System.Collections.Queue
$workSheet		= $WorkBook.sheets.item("vcsa")
$rows			= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data			= $Worksheet.Range("A2","AA$rows").Value()
	$s_Deployments	= @()
	for ($i=1;$i -lt $rows;$i++) {
		$s_Deployment  = [PSCustomObject]@{
			Action			= $data[$i,1]
			Config			= $([System.Convert]::ToBoolean($($data[$i,2])))
			Certs			= $([System.Convert]::ToBoolean($($data[$i,3])))
			vmName			= $data[$i,4]
			Hostname		= $data[$i,5]
			VCSARootPass	= $data[$i,6]
			NetMode			= $data[$i,7]
			NetFamily		= $data[$i,8]	
			NetPrefix		= $data[$i,9]
			JumboFrames		= $([System.Convert]::ToBoolean($($data[$i,10])))
			IP				= $data[$i,11]
			Gateway			= $data[$i,12]
			DNS				= $data[$i,13]
			NTP				= $data[$i,14]
			EnableSSH		= $data[$i,15]
			DiskMode		= $data[$i,16]
			DeployType		= $data[$i,17]
			esxiHost		= $data[$i,18]
			esxiNet			= $data[$i,19]
			esxiDatastore	= $data[$i,20]
			esxiRootUser	= $data[$i,21]
			esxiRootPass	= $data[$i,22]
			Parent			= $data[$i,23]
			SSODomainName	= $data[$i,24]
			SSOSiteName		= $data[$i,25]
			SSOAdminPass	= $data[$i,26]
			OVA				= "$PSScriptRoot\$($data[$i,27])"
		}
		$s_Deployments += $s_Deployment

		$scrub += $s_Deployment.VCSARootPass
		$scrub += $s_Deployment.esxiRootPass
		$scrub += $s_Deployment.SSOAdminPass
	}
	echo $s_Deployments | Out-String

    $s_Deployments | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\deployments.json"

	removenull $s_Deployments

    $s_Deployments | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\deployments.yml"
}



# get Licenses
$workSheet	= $WorkBook.sheets.item("licenses")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","D$rows").Value()
	$s_Licenses	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_License = [PSCustomObject]@{
			vCenter		= $data[$i,1]
			LicKey		= $data[$i,2]
			ApplyTo		= $data[$i,3]
			ApplyType	= $data[$i,4]
		}
		$s_Licenses += $s_License
	}
	echo $s_Licenses | Out-String

    $s_Licenses | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\licenses.json"

	removenull $s_Licenses

    $s_Licenses | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\licenses.yml"
}



# get Roles
$workSheet	= $WorkBook.sheets.item("roles")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","C$rows").Value()
	$s_Roles	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_Role = [PSCustomObject]@{
			Name		= $data[$i,1]
			Privilege	= $data[$i,2]
			vCenter		= $data[$i,3]
		}
		$s_Roles += $s_Role
	}
	echo $s_Roles | Out-String

    $s_Roles | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\roles.json"

	removenull $s_Roles

    $s_Roles | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\roles.yml"
}



# get Services
$workSheet	= $WorkBook.sheets.item("services")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","B$rows").Value()
	$s_Services	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_Service = [PSCustomObject]@{
			vCenter	= $data[$i,1]
			Service	= $data[$i,2]
		}
		$s_Services += $s_Service
	}
	echo $s_Services | Out-String

    $s_Services | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\services.json"

	removenull $s_Services

    $s_Services | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\services.yml"
}



# get sites
$workSheet	= $WorkBook.sheets.item("sites")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data 		= $Worksheet.Range("A2","E$rows").Value()
	$s_sites	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_site = [PSCustomObject]@{
			Datacenter	= $data[$i,1]
			oct1		= $data[$i,2]
			oct2		= $data[$i,3]
			oct3		= $data[$i,4]
			vCenter		= $data[$i,5]
		}
		$s_sites += $s_site
	}
	echo $s_sites | Out-String

    $s_sites | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\sites.json"

	removenull $s_sites

    $s_sites | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\sites.yml"
}



# get vdswitches
$workSheet	= $WorkBook.sheets.item("vdswitches")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data 			= $Worksheet.Range("A2","E$rows").Value()
	$s_vdswitches	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_vdswitch = [PSCustomObject]@{
			vDSwitchName	= $($data[$i,1].ToString() + " " + $data[$i,2].ToString())
			Datacenter		= $data[$i,3]
			vCenter			= $data[$i,4]
			Version			= $data[$i,5]
		}
		$s_vdswitches += $s_vdswitch
	}
	echo $s_vdswitches | Out-String

    $s_vdswitches | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\vdswitches.json"

	removenull $s_vdswitches

    $s_vdswitches | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\vdswitches.yml"
}


# get vlans
$workSheet	= $WorkBook.sheets.item("vlans")
$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")

If ( $rows -gt 1 -and $rows -lt $lastrow) {
	$data		= $Worksheet.Range("A2","F$rows").Value()
	$s_vlans 	= @()
	for ($i=1;$i -lt $rows;$i++){
		$s_vlan = [PSCustomObject]@{
			vlan        = $($data[$i,1].padright(8," ") +`
						    $data[$i,2].padright(8," ") + "- " +`
						    $data[$i,3].padright(19," ") + "- " +`
						    $data[$i,4])
			Datacenter  = $data[$i,5]
			vCenter     = $data[$i,6]
		}
		$s_vlans += $s_vlan
	}
	echo $s_vlans | Out-String

    $s_vlans | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\vlans.json"

	removenull $s_vlans

    $s_vlans | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\vlans.yml"
}

$workSheet	= $WorkBook.sheets.item("Summary")

$TranscriptScrub = [System.Convert]::ToBoolean($($Worksheet.Range("B1","B1").Value()))

$workbook.Close($false)
$objExcel.Quit()

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workSheet)
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($objExcel)

Remove-Variable -Name Objexcel
