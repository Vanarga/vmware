# ---------------------  Load Parameters from Excel ------------------------------

# https://kevinmarquette.github.io/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/#creating-a-pscustomobject
import-module powershell-yaml
cls

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook

function RemoveNull
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	$InputObject | %{$_.psobject.properties | ?{!$_.value -and $_.TypeNameOfValue -ne "System.Boolean"} | %{$_.value = "<null>"}}
}

function ReplaceNull
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	$InputObject = $InputObject | %{$_.psobject.Properties.Value -replace "<null>",$null}
}

function SaveToYaml
{
    param (
		[Parameter(Mandatory=$true, Position=0)]
		$InputObject,
		[Parameter(Mandatory=$true, Position=1)]
		$FileName
	)

	removenull $InputObject

	$InputObject | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path "$PSScriptRoot\yaml\$FileName.yml"
}

function SaveToJson
{
    param (
		[Parameter(Mandatory=$true, Position=0)]
		$InputObject,
		[Parameter(Mandatory=$true, Position=1)]
		$FileName
	)

	removenull $InputObject

	$InputObject | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\json\$FileName.json"
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

function ConvertPSObjectToExcel {
    param (
        [Parameter(Mandatory=$true, Position=0)]
		$InputObject,
        [Parameter(Mandatory=$true, Position=1)]
		$WorkSheet,		
		[Parameter(Mandatory=$true, Position=2)]
		$SheetName,
		[Parameter(Mandatory=$true, Position=3)]
		$Excelpath
	)
	$mystack = new-object system.collections.stack
		

	$headers = $InputObject[0].PSObject.Properties.Name
	$values  = $InputObject | %{$_.psobject.properties.Value}
	
	If ($headers.count -gt 1) {
		$values[($values.length - 1)..0] | %{$mystack.Push($_)}
		$headers[($headers.length - 1)..0] | %{$mystack.Push($_)}
	}
	else {
		$values	 | %{$mystack.Push($_)}
		$headers | %{$mystack.Push($_)}
	}			
	
	$columns = $headers.count
	$rows = $values.count/$headers.count + 1
	$array = New-Object 'object[,]' $rows, $columns
		
	for ($i=0;$i -lt $rows;$i++)
		{ 
			for ($j = 0; $j -lt $columns; $j++) {
				$array[$i,$j] = $mystack.Pop()
			}
		}

	$WorkSheet.name = $SheetName
	If ($columns -le 26) {
		$ascii = [char]($columns + 96) + $rows
	} else { $ascii = "aa" + $rows}
	$range = $WorkSheet.Range("a1",$ascii)
	$range.Value2 = $array
}
Write-Host "Enter Source File Type:"
Write-Host "Excel: 1"
Write-Host "Json:  2"
Write-Host "Yaml:  3"
$Source = Read-Host

### Load from Excel
switch ($Source) {
	1 {
			# Source Excel Path
			$ExcelFilePathSrc = "$PSScriptRoot\vsphere-configs.xlsx"
			
			# Create an Object Excel.Application using Com interface
			$objExcel = New-Object -ComObject Excel.Application
			
			# Disable the 'visible' property so the document won't open in excel
			$objExcel.Visible = $false
			
			# Open the Excel file and save it in $WorkBook
			$workBook 		= $objExcel.Workbooks.Open($ExcelFilePathSrc)
			
			# get ad info
			$workSheet	= $WorkBook.sheets.item("adinfo")
			$lastrow	= $worksheet.Range("A:A").count
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			### Get Excel
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
				}
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
			}
			
			# get OS Customizations
			$workSheet	= $WorkBook.sheets.item("OS")
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ( $rows -gt 1 -and $rows -lt $lastrow) {
				$data				= $Worksheet.Range("A2","Y$rows").Value()
				$s_Customizations	= @()
				$s_CustomPasswords  = @()
				
				for ($i=1;$i -lt $rows;$i++){
					$s_Customization  = [PSCustomObject]@{
						OSType					= $data[$i,1]
						Server					= $data[$i,2]	
						Name					= $data[$i,3]	
						Type					= $data[$i,4]
						DnsServer				= $data[$i,5]
						DnsSuffix				= $data[$i,6]
						Domain					= $data[$i,7]	
						NamingScheme			= $data[$i,8]	
						NamingPrefix			= $data[$i,9]
						Description				= $data[$i,10]
						Spec					= $data[$i,11]
						Fullname				= $data[$i,12]	
						OrgName					= $data[$i,13]	
						ChangeSid				= $([System.Convert]::ToBoolean($($data[$i,14])))
						DeleteAccounts			= $([System.Convert]::ToBoolean($($data[$i,15])))
						GuiRunOnce				= $data[$i,16]
						AdminPassword			= $data[$i,17]	
						TimeZone				= $data[$i,18]	
						AutoLogonCount			= $data[$i,19]
						Workgroup				= $data[$i,20]
						DomainUserName			= $data[$i,21]
						DomainPassword			= $data[$i,22]	
						ProductKey				= $data[$i,23]	
						LicenseMode				= $data[$i,24]
						LicenseMaxConnections	= $data[$i,25]
					}
					$s_Customizations += $s_Customization
				}
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
				}
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
			}
			
			# get vdswitches
			$workSheet	= $WorkBook.sheets.item("vdswitches")
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ( $rows -gt 1 -and $rows -lt $lastrow) {
				$data 			= $Worksheet.Range("A2","E$rows").Value()
				$s_vdswitches	= @()
				for ($i=1;$i -lt $rows;$i++){
					$s_vdswitch = [PSCustomObject]@{
						SwitchNumber    = $data[$i,1]
						vDSwitchName	= $data[$i,2]
						Datacenter		= $data[$i,3]
						vCenter			= $data[$i,4]
						Version			= $data[$i,5]
					}     
					$s_vdswitches += $s_vdswitch
				}
			}
			
			# get vlans
			$workSheet	= $WorkBook.sheets.item("vlans")
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ( $rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","F$rows").Value()
				$s_vlans 	= @()
				for ($i=1;$i -lt $rows;$i++){
					$s_vlan = [PSCustomObject]@{
						Number      = $data[$i,1]
						Vlan		= $data[$i,2]
						Network		= $data[$i,3]
						VlanName    = $data[$i,4]
						Datacenter  = $data[$i,5]
						vCenter     = $data[$i,6]
					}
					$s_vlans += $s_vlan
				}
			}
			
			$workSheet	= $WorkBook.sheets.item("Summary")

            $s_summary = [PSCustomObject]@{
                TranscriptScrub = [System.Convert]::ToBoolean($Worksheet.Range("A2","A2").Value())
            }
            
            $workbook.Close($false)
			$objExcel.Quit()
			

			[System.GC]::Collect()
			[System.GC]::WaitForPendingFinalizers()
			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($worksheet)
			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workbook)
			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($objExcel)
		}
	
	2 { 	
			$Json_Dir = $PSScriptRoot + "\Json"
			$s_adinfo			= Get-Content -Raw -Path "$Json_Dir\ad-info.json" 			| ConvertFrom-Json
			$s_plugins			= Get-Content -Raw -Path "$Json_Dir\plugins.json"			| ConvertFrom-Json
			$s_arules			= Get-Content -Raw -Path "$Json_Dir\autodeploy-rules.json"	| ConvertFrom-Json
			$s_Certinfo			= Get-Content -Raw -Path "$Json_Dir\cert-info.json"			| ConvertFrom-Json
			$s_clusters			= Get-Content -Raw -Path "$Json_Dir\cluster-info.json"		| ConvertFrom-Json
			$s_folders			= Get-Content -Raw -Path "$Json_Dir\folders.json"			| ConvertFrom-Json
			$s_Permissions		= Get-Content -Raw -Path "$Json_Dir\permissions.json"		| ConvertFrom-Json
			$s_Customizations	= Get-Content -Raw -Path "$Json_Dir\os-customizations.json"	| ConvertFrom-Json
			$s_Deployments		= Get-Content -Raw -Path "$Json_Dir\deployments.json"		| ConvertFrom-Json
			$s_Licenses			= Get-Content -Raw -Path "$Json_Dir\licenses.json"			| ConvertFrom-Json
			$s_Roles			= Get-Content -Raw -Path "$Json_Dir\roles.json"				| ConvertFrom-Json
			$s_Services			= Get-Content -Raw -Path "$Json_Dir\services.json"			| ConvertFrom-Json
			$s_sites			= Get-Content -Raw -Path "$Json_Dir\sites.json"				| ConvertFrom-Json
			$s_vdswitches		= Get-Content -Raw -Path "$Json_Dir\vdswitches.json"		| ConvertFrom-Json
			$s_vlans			= Get-Content -Raw -Path "$Json_Dir\vlans.json"				| ConvertFrom-Json
			$s_summary          = Get-Content -Raw -Path "$Json_Dir\summary.json"			| ConvertFrom-Json
		}
		
	3 {
			$Yaml_Dir = $PSScriptRoot + "\Yaml"
			$s_adinfo			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\ad-info.yml" 	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_plugins			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\plugins.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_arules			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\autodeploy-rules.yml"  | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Certinfo			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cert-info.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_clusters			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cluster-info.yml"      | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_folders			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\folders.yml"	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Permissions		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\permissions.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Customizations	= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\os-customizations.yml"	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Deployments		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\deployments.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Licenses			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\licenses.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Roles			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\roles.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_Services			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\services.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_sites			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\sites.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_vdswitches		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vdswitches.yml"  		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_vlans			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vlans.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$s_summary          = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\summary.yml"	    	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)

			for ($i=0;$i -lt ($s_vlans | Measure-Object).count;$i++) {
				$s_vlans[$i].psobject.properties | ?{if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
			}
		}
}

echo $s_adinfo          | Out-String
echo $s_plugins         | Out-String
echo $s_arules          | Out-String
echo $s_Certinfo        | Out-String
echo $s_clusters        | Out-String
echo $s_folders         | Out-String
echo $s_Permissions     | Out-String
echo $s_Customizations  | Out-String
echo $s_Deployments     | Out-String
echo $s_Licenses        | Out-String
echo $s_Roles           | Out-String
echo $s_Services        | Out-String
echo $s_sites           | Out-String
echo $s_vdswitches      | Out-String
echo $s_vlans           | Out-String
echo $s_summary         | Out-String

# Password Scrub array for redacting passwords from Transcript.
If ($s_summary.TranscriptScrub) {
    $scrub = @()
    $scrub += $s_adinfo.ADJoinPass
    $scrub += $s_adinfo.ADvmcamPass
    $scrub += $s_arule.ProfileRootPassword
    $scrub += $s_Deployment.VCSARootPass
    $scrub += $s_Deployment.esxiRootPass
    $scrub += $s_Deployment.SSOAdminPass
}

### Save to Excel
If ($Source -ne 1) {
	$ExcelFilePathDst = "$PSScriptRoot\vsphere-configs.xlsx"
	If (Test-Path -Path $ExcelFilePathDst) {Remove-Item -Path $ExcelFilePathDst -Confirm:$false -Force}
	
	$objExcelDst = New-Object -ComObject Excel.Application
	$objExcelDst.Visible = $false
	$workBookDst = $objExcelDst.Workbooks.Add()
	$worksheetcount = 16 - ($workBookDst.worksheets | measure-object).count

	# http://www.planetcobalt.net/sdb/vba2psh.shtml
	$def = [Type]::Missing
	$null = $objExcelDst.Worksheets.Add($def,$def,$worksheetcount,$def)

	ConvertPSObjectToExcel -InputObject $s_vlans -WorkSheet $workBookDst.Worksheets.Item("Sheet3") -SheetName "vlans" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_vdswitches -WorkSheet $workBookDst.Worksheets.Item("Sheet2") -SheetName "vdswitches" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Deployments -WorkSheet $workBookDst.Worksheets.Item("Sheet1") -SheetName "vcsa" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_sites -WorkSheet $workBookDst.Worksheets.Item("Sheet4") -SheetName "sites" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Services -WorkSheet $workBookDst.Worksheets.Item("Sheet5") -SheetName "services" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Roles -WorkSheet $workBookDst.Worksheets.Item("Sheet6") -SheetName "roles" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_plugins -WorkSheet $workBookDst.Worksheets.Item("Sheet7") -SheetName "plugins" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Permissions -WorkSheet $workBookDst.Worksheets.Item("Sheet8") -SheetName "permissions" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Customizations -WorkSheet $workBookDst.Worksheets.Item("Sheet9") -SheetName "OS" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Licenses -WorkSheet $workBookDst.Worksheets.Item("Sheet10") -SheetName "licenses" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_folders -WorkSheet $workBookDst.Worksheets.Item("Sheet11") -SheetName "folders" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_clusters -WorkSheet $workBookDst.Worksheets.Item("Sheet12") -SheetName "clusters" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_Certinfo -WorkSheet $workBookDst.Worksheets.Item("Sheet13") -SheetName "certs" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_arules -WorkSheet $workBookDst.Worksheets.Item("Sheet14") -SheetName "autodeploy" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $s_adinfo -WorkSheet $workBookDst.Worksheets.Item("Sheet15") -SheetName "adinfo" -Excelpath $ExcelFilePathDst
    ConvertPSObjectToExcel -InputObject $s_summary -WorkSheet $workBookDst.Worksheets.Item("Sheet16") -SheetName "summary" -Excelpath $ExcelFilePathDst
	
	$objExcelDst.DisplayAlerts = $False
	$objExcelDst.ActiveWorkbook.SaveAs($ExcelFilePathDst,$xlFixedFormat)
	$workBookDst.Close($false)
	$objExcelDst.Quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workBookDst)
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($objExcelDst)
}

### Save to Json
If ($Source -ne 2) {
	If (!(Test-Path -Path "$PSScriptRoot\Json")) {New-Item "$PSScriptRoot\Json" -Type Directory}
	SaveToJson -InputObject $s_adinfo -FileName "ad-info"
	SaveToJson -InputObject $s_plugins -FileName "plugins"
	SaveToJson -InputObject $s_arules -FileName "autodeploy-rules"
	SaveToJson -InputObject $s_Certinfo -FileName "cert-info"
	SaveToJson -InputObject $s_clusters -FileName "cluster-info"
	SaveToJson -InputObject $s_folders -FileName "folders"
	SaveToJson -InputObject $s_Permissions -FileName "permissions"
	SaveToJson -InputObject $s_Customizations -FileName "os-customizations"
	SaveToJson -InputObject $s_Deployments -FileName "deployments"
	SaveToJson -InputObject $s_Licenses -FileName "licenses"
	SaveToJson -InputObject $s_Roles -FileName "roles"
    SaveToJson -InputObject $s_Services -FileName "services"
    SaveToJson -InputObject $s_sites -FileName "sites"
    SaveToJson -InputObject $s_vdswitches -FileName "vdswitches"
    SaveToJson -InputObject $s_vlans -FileName "vlans"
    SaveToJson -InputObject $s_summary -FileName "summary"
}

### Save to Yaml
If ($Source -ne 3) {
	If (!(Test-Path -Path "$PSScriptRoot\Yaml")) {New-Item "$PSScriptRoot\Yaml" -Type Directory}
	SaveToYaml -InputObject $s_adinfo -FileName "ad-info"
	SaveToYaml -InputObject $s_plugins -FileName "plugins"
	SaveToYaml -InputObject $s_arules -FileName "autodeploy-rules"
	SaveToYaml -InputObject $s_Certinfo -FileName "cert-info"
	SaveToYaml -InputObject $s_clusters -FileName "cluster-info"
	SaveToYaml -InputObject $s_folders -FileName "folders"
	SaveToYaml -InputObject $s_Permissions -FileName "permissions"
	SaveToYaml -InputObject $s_Customizations -FileName "os-customizations"
	SaveToYaml -InputObject $s_Deployments -FileName "deployments"
	SaveToYaml -InputObject $s_Licenses -FileName "licenses"
	SaveToYaml -InputObject $s_Roles -FileName "roles"
	SaveToYaml -InputObject $s_Services -FileName "services"
	SaveToYaml -InputObject $s_sites -FileName "sites"
	SaveToYaml -InputObject $s_vdswitches -FileName "vdswitches"

	for ($i=0;$i -lt ($s_vlans | Measure-Object).count;$i++) {
		$s_vlans[$i].psobject.properties | ?{if ($_.name -eq "network") {$commacorrect = $_.value -replace ",",':'; $_.value = $commacorrect}}
	}
	
    SaveToYaml -InputObject $s_vlans -FileName "vlans"
    SaveToYaml -InputObject $s_summary -FileName "summary"
}

cls
#[System.GC]::Collect()
#[System.GC]::WaitForPendingFinalizers()

#https://social.technet.microsoft.com/Forums/scriptcenter/en-US/81dcbbd7-f6cc-47ec-8537-db23e5ae5e2f/excel-releasecomobject-doesnt-work?forum=ITCG
#[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($range)
