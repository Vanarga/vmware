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
		$ObjExcel = New-Object -ComObject Excel.Application

		# Disable the 'visible' property so the Document won't open in excel
		$ObjExcel.Visible = $false

		# Open the Excel file and save it in $WorkBook
		$WorkBook 	= $ObjExcel.Workbooks.Open($ExcelFilePathSrc)

		# get ad info
		$WorkSheet	= $WorkBook.Sheets.Item("adinfo")
		$LastRow	= $WorkSheet.Range("A:A").count
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		### Get Excel
		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data	  = $WorkSheet.Range("A2","G$Rows").Value()
			$SrcADInfo = @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					ADDomain        = $Data[$i,1]
					ADJoinUser		= $Data[$i,2]
					ADJoinPass		= $Data[$i,3]
					ADvCenterAdmins	= $Data[$i,4]
					ADVMCamUser		= $Data[$i,5]
					ADvmcamPass		= $Data[$i,6]
					vCenter			= $Data[$i,7]
				}
				$SrcADInfo += $ReadDataLine
			}
		}

		# get plugins
		$WorkSheet	= $WorkBook.Sheets.Item("plugins")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data 		= $WorkSheet.Range("A2","F$Rows").Value()
			$SrcPlugins	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					Config 			= $Data[$i,1]
					vCenter 		= $Data[$i,2]
					SourceDir 		= $Data[$i,3]
					DestDir 		= $Data[$i,4]
					SourceFiles 	= $Data[$i,5]
					Command 		= $Data[$i,6]
				}
				$SrcPlugins += $ReadDataLine
			}
		}

		# get autodeploy rules
		$WorkSheet	= $WorkBook.Sheets.Item("autodeploy")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data	  = $WorkSheet.Range("A2","K$Rows").Value()
			$SrcAutoDepRules = @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					vCenter					= $Data[$i,1]
					RuleName				= $Data[$i,2]
					ProfileImport			= $Data[$i,3]
					ProfileName				= $Data[$i,4]
					ProfileRootPassword     = $Data[$i,5]
					ProfileAnnotation		= $Data[$i,6]
					Datacenter				= $Data[$i,7]
					Cluster					= $Data[$i,8]
					SoftwareDepot			= $Data[$i,9]
					Pattern					= $Data[$i,10]
					Activate				= $Data[$i,11]
				}
				$SrcAutoDepRules += $ReadDataLine
			}
		}

		# get certificate info
		$WorkSheet	= $WorkBook.Sheets.Item("certs")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("B:B"),"<>")
		$Data = $null

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
               $Data		= $WorkSheet.Range("A2","U$Rows").Value()
               $SrcCertInfo = @()
			For ($i=1;$i -lt $Rows;$i++) {
			    $ReadDataLine = [PSCustomObject]@{
				    openssldir		= $Data[$i,1]
				    RootCA			= $Data[$i,2]
				    SubCA1			= $Data[$i,3]
                    SubCA2			= $Data[$i,4]
                    Username		= $Data[$i,5]
                    Password		= $Data[$i,6]
				    CompanyName     = $Data[$i,7]
				    OrgName		    = $Data[$i,8]
				    OrgUnit			= $Data[$i,9]
				    State			= $Data[$i,10]
				    Locality		= $Data[$i,11]
				    Country			= $Data[$i,12]
				    Email			= $Data[$i,13]
				    CADownload	    = $Data[$i,14]
				    IssuingCA		= $Data[$i,15]
				    V6Template	    = $Data[$i,16]
				    SubTemplate	   	= $Data[$i,17]
				    RootRenewal		= $Data[$i,18]
				    SubRenewal1		= $Data[$i,19]
                       SubRenewal2		= $Data[$i,20]
                       vCenter         = $Data[$i,21]
                   }
                   If ($SrcCertinfo.SubCA1 -eq "null") {$SrcCertinfo.SubCA1 = $null}
                   If ($SrcCertinfo.SubCA2 -eq "null") {$SrcCertinfo.SubCA2 = $null}
                   $SrcCertInfo += $ReadDataLine
			}
		}

		# get clusters
		$WorkSheet	= $WorkBook.Sheets.Item("clusters")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data 		= $WorkSheet.Range("A2","C$Rows").Value()
			$SrcClusters = @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine  = [PSCustomObject]@{
					ClusterName     = $Data[$i,1]
					Datacenter		= $Data[$i,2]
					vCenter			= $Data[$i,3]
				}
				$SrcClusters += $ReadDataLine
			}
		}

		# get folders
		$WorkSheet	= $WorkBook.Sheets.Item("folders")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data		= $WorkSheet.Range("A2","F$Rows").Value()
			$SrcFolders	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine  = [PSCustomObject]@{
					Name		= $Data[$i,1]
					Location	= $Data[$i,2]
					Type		= $Data[$i,3]
					Datacenter	= $Data[$i,4]
					vCenter		= $Data[$i,5]
					Tier		= $Data[$i,6]
				}
				$SrcFolders += $ReadDataLine
			}
			$SrcFolders = $SrcFolders | Sort-Object -Property Tier, Name
		}

		# get Permissions
		$WorkSheet	= $WorkBook.Sheets.Item("permissions")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data			= $WorkSheet.Range("A2","G$Rows").Value()
			$SrcPermissions	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					Entity		= $Data[$i,1]
					Location	= $Data[$i,2]
					Principal	= $Data[$i,3]
					Group		= $Data[$i,4]
					Propagate	= $Data[$i,5]
					Role		= $Data[$i,6]
					vCenter		= $Data[$i,7]
				}
				$SrcPermissions += $ReadDataLine
			}
		}

		# get OS Customizations
		$WorkSheet	= $WorkBook.Sheets.Item("OS")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ( $Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data				= $WorkSheet.Range("A2","Y$Rows").Value()
			$SrcOSCustomizations	= @()

			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine  = [PSCustomObject]@{
					OSType					= $Data[$i,1]
					vCenter					= $Data[$i,2]
					Name					= $Data[$i,3]
					Type					= $Data[$i,4]
					DnsServer				= $Data[$i,5]
					DnsSuffix				= $Data[$i,6]
					Domain					= $Data[$i,7]
					NamingScheme			= $Data[$i,8]
					NamingPrefix			= $Data[$i,9]
					Description				= $Data[$i,10]
					Spec					= $Data[$i,11]
					Fullname				= $Data[$i,12]
					OrgName					= $Data[$i,13]
					ChangeSid				= $Data[$i,14]
					DeleteAccounts			= $Data[$i,15]
					GuiRunOnce				= $Data[$i,16]
					AdminPassword			= $Data[$i,17]
					TimeZone				= $Data[$i,18]
					AutoLogonCount			= $Data[$i,19]
					Workgroup				= $Data[$i,20]
					DomainUserName			= $Data[$i,21]
					DomainPassword			= $Data[$i,22]
					ProductKey				= $Data[$i,23]
					LicenseMode				= $Data[$i,24]
					LicenseMaxConnections	= $Data[$i,25]
				}
				$SrcOSCustomizations += $ReadDataLine
			}
		}

		# get Deployments
		$SrcDeployments	= @()
		$WorkSheet		= $WorkBook.Sheets.Item("vcsa")
		$Rows			= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data			= $WorkSheet.Range("A2","AA$Rows").Value()
			$SrcDeployments	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine  = [PSCustomObject]@{
					Action			= $Data[$i,1]
					Config			= $Data[$i,2]
					Certs			= $Data[$i,3]
					vmName			= $Data[$i,4]
					Hostname		= $Data[$i,5]
					VCSARootPass	= $Data[$i,6]
					NetMode			= $Data[$i,7]
					NetFamily		= $Data[$i,8]
					NetPrefix		= $Data[$i,9]
					JumboFrames		= $Data[$i,10]
					IP				= $Data[$i,11]
					Gateway			= $Data[$i,12]
					DNS				= $Data[$i,13]
					NTP				= $Data[$i,14]
					EnableSSH		= $Data[$i,15]
					DiskMode		= $Data[$i,16]
					DeployType		= $Data[$i,17]
					esxiHost		= $Data[$i,18]
					esxiNet			= $Data[$i,19]
					esxiDatastore	= $Data[$i,20]
					esxiRootUser	= $Data[$i,21]
					esxiRootPass	= $Data[$i,22]
					Parent			= $Data[$i,23]
					SSODomainName	= $Data[$i,24]
					SSOSiteName		= $Data[$i,25]
					SSOAdminPass	= $Data[$i,26]
					OVA				= "$FolderPath\$($Data[$i,27])"
				}
				$SrcDeployments+= $ReadDataLine
			}
		}

		# get Licenses
		$WorkSheet	= $WorkBook.Sheets.Item("licenses")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data		= $WorkSheet.Range("A2","D$Rows").Value()
			$SrcLicenses	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					vCenter		= $Data[$i,1]
					LicKey		= $Data[$i,2]
					ApplyTo		= $Data[$i,3]
					ApplyType	= $Data[$i,4]
				}
				$SrcLicenses += $ReadDataLine
			}
		}

		# get Roles
		$WorkSheet	= $WorkBook.Sheets.Item("roles")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data		= $WorkSheet.Range("A2","C$Rows").Value()
			$SrcRoles	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					Name		= $Data[$i,1]
					Privilege	= $Data[$i,2]
					vCenter		= $Data[$i,3]
				}
				$SrcRoles += $ReadDataLine
			}
		}

		# get Services
		$WorkSheet	= $WorkBook.Sheets.Item("services")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data		= $WorkSheet.Range("A2","B$Rows").Value()
			$SrcServices	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					vCenter	= $Data[$i,1]
					Service	= $Data[$i,2]
				}
				$SrcServices += $ReadDataLine
			}
		}

		# get sites
		$WorkSheet	= $WorkBook.Sheets.Item("sites")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data 		= $WorkSheet.Range("A2","E$Rows").Value()
			$SrcSites	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					Datacenter	= $Data[$i,1]
					oct1		= $Data[$i,2]
					oct2		= $Data[$i,3]
					oct3		= $Data[$i,4]
					vCenter		= $Data[$i,5]
				}
				$SrcSites += $ReadDataLine
			}
		}

		# get vdswitches
		$WorkSheet	= $WorkBook.Sheets.Item("vdswitches")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data 			= $WorkSheet.Range("A2","F$Rows").Value()
			$SrcVDSwitches	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					SwitchNumber    = $Data[$i,1]
					vDSwitchName	= $Data[$i,2]
					Datacenter		= $Data[$i,3]
					vCenter			= $Data[$i,4]
                       Version			= $Data[$i,5]
                       JumboFrames     = $Data[$i,6]
				}
				$SrcVDSwitches += $ReadDataLine
			}
		}

		# get vlans
		$WorkSheet	= $WorkBook.Sheets.Item("vlans")
		$Rows		= $ObjExcel.Worksheetfunction.Countif($WorkSheet.Range("A:A"),"<>")

		If ($Rows -gt 1 -and $Rows -lt $LastRow) {
			$Data		= $WorkSheet.Range("A2","F$Rows").Value()
			$SrcVLANS 	= @()
			For ($i=1;$i -lt $Rows;$i++) {
				$ReadDataLine = [PSCustomObject]@{
					Number      = $Data[$i,1]
					Vlan		= $Data[$i,2]
					Network		= $Data[$i,3]
					VlanName    = $Data[$i,4]
					Datacenter  = $Data[$i,5]
					vCenter     = $Data[$i,6]
				}
				$SrcVLANS += $ReadDataLine
			}
		}

		$WorkSheet	= $WorkBook.Sheets.Item("Summary")

           $SrcSummary = [PSCustomObject]@{
               TranscriptScrub = $WorkSheet.Range("A2","A2").Value()
           }

           $WorkBook.Close($false)
		$ObjExcel.Quit()

		[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($WorkSheet)
		[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($WorkBook)
		[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ObjExcel)

		$WorkSheet	= $null
		$WorkBook	= $null
		$ObjExcel		= $null

		[System.GC]::Collect()
		[System.GC]::WaitForPendingFinalizers()
		}

	2 {
		$Json_Dir = $PSScriptRoot + "\Json"
		$SrcADInfo			 = Get-Content -Raw -Path "$Json_Dir\ad-info.json" 				| ConvertFrom-Json
		$SrcPlugins			 = Get-Content -Raw -Path "$Json_Dir\plugins.json"				| ConvertFrom-Json
		$SrcAutoDepRules	 = Get-Content -Raw -Path "$Json_Dir\autodeploy-rules.json"		| ConvertFrom-Json
		$SrcCertInfo		 = Get-Content -Raw -Path "$Json_Dir\cert-info.json"			| ConvertFrom-Json
		$SrcClusters		 = Get-Content -Raw -Path "$Json_Dir\cluster-info.json"			| ConvertFrom-Json
		$SrcFolders			 = Get-Content -Raw -Path "$Json_Dir\folders.json"				| ConvertFrom-Json
		$SrcPermissions		 = Get-Content -Raw -Path "$Json_Dir\permissions.json"			| ConvertFrom-Json
		$SrcOSCustomizations = Get-Content -Raw -Path "$Json_Dir\os-customizations.json"	| ConvertFrom-Json
		$SrcDeployments		 = Get-Content -Raw -Path "$Json_Dir\deployments.json"			| ConvertFrom-Json
		$SrcLicenses		 = Get-Content -Raw -Path "$Json_Dir\licenses.json"				| ConvertFrom-Json
		$SrcRoles			 = Get-Content -Raw -Path "$Json_Dir\roles.json"				| ConvertFrom-Json
		$SrcServices		 = Get-Content -Raw -Path "$Json_Dir\services.json"				| ConvertFrom-Json
		$SrcSites			 = Get-Content -Raw -Path "$Json_Dir\sites.json"				| ConvertFrom-Json
		$SrcVDSwitches		 = Get-Content -Raw -Path "$Json_Dir\vdswitches.json"			| ConvertFrom-Json
		$SrcVLANS			 = Get-Content -Raw -Path "$Json_Dir\vlans.json"				| ConvertFrom-Json
		$SrcSummary          = Get-Content -Raw -Path "$Json_Dir\summary.json"				| ConvertFrom-Json
		}

	3 {
			$Yaml_Dir = $PSScriptRoot + "\Yaml"
			$SrcADInfo			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\ad-info.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcPlugins			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\plugins.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcAutoDepRules	 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\autodeploy-rules.yml"		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcCertInfo		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cert-info.yml"			| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcClusters		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cluster-info.yml"			| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcFolders			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\folders.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcPermissions		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\permissions.yml"			| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcOSCustomizations = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\os-customizations.yml"	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcDeployments		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\deployments.yml"			| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcLicenses		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\licenses.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcRoles			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\roles.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcServices		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\services.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcSites			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\sites.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcVDSwitches		 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vdswitches.yml"			| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcVLANS			 = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vlans.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcSummary          = [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\summary.yml"				| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
		}
}

echo $SrcADInfo				| Out-String
echo $SrcPlugins			| Out-String
echo $SrcAutoDepRules		| Out-String
echo $SrcCertInfo			| Out-String
echo $SrcClusters			| Out-String
echo $SrcFolders			| Out-String
echo $SrcPermissions		| Out-String
echo $SrcOSCustomizations	| Out-String
echo $SrcDeployments		| Out-String
echo $SrcLicenses			| Out-String
echo $SrcRoles				| Out-String
echo $SrcServices			| Out-String
echo $SrcSites				| Out-String
echo $SrcVDSwitches			| Out-String
echo $SrcVLANS				| Out-String
echo $SrcSummary			| Out-String

# Password Scrub array for redacting passwords from Transcript.
If ($SrcSummary.TranscriptScrub) {
    $scrub = @()
    $scrub += $SrcADInfo.ADJoinPass
    $scrub += $SrcADInfo.ADvmcamPass
    $scrub += $SrcAutoDepRules.ProfileRootPassword
    $scrub += $SrcDeployments.VCSARootPass
    $scrub += $SrcDeployments.esxiRootPass
    $scrub += $SrcDeployments.SSOAdminPass
}

### Save to Excel
If ($Source -ne 1) {
	$ExcelFilePathDst = "$PSScriptRoot\vsphere-configs.xlsx"
	If (Test-Path -Path $ExcelFilePathDst) {Remove-Item -Path $ExcelFilePathDst -Confirm:$false -Force}

	$objExcelDst = New-Object -ComObject Excel.Application
	$objExcelDst.Visible = $false
	$workBookDst = $objExcelDst.Workbooks.Add()

	ConvertPSObjectToExcel -InputObject $SrcVLANS -WorkSheet $workBookDst.Worksheets.Item("Sheet3") -SheetName "vlans" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcVDSwitches -WorkSheet $workBookDst.Worksheets.Item("Sheet2") -SheetName "vdswitches" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcDeployments -WorkSheet $workBookDst.Worksheets.Item("Sheet1") -SheetName "vcsa" -Excelpath $ExcelFilePathDst

	# http://www.planetcobalt.net/sdb/vba2psh.shtml
	$def = [Type]::Missing
	$null = $objExcelDst.Worksheets.Add($def,$def,13,$def)

	ConvertPSObjectToExcel -InputObject $SrcSites -WorkSheet $workBookDst.Worksheets.Item("Sheet4") -SheetName "sites" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcServices -WorkSheet $workBookDst.Worksheets.Item("Sheet5") -SheetName "services" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcRoles -WorkSheet $workBookDst.Worksheets.Item("Sheet6") -SheetName "roles" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcPlugins -WorkSheet $workBookDst.Worksheets.Item("Sheet7") -SheetName "plugins" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcPermissions -WorkSheet $workBookDst.Worksheets.Item("Sheet8") -SheetName "permissions" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcOSCustomizations -WorkSheet $workBookDst.Worksheets.Item("Sheet9") -SheetName "OS" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcLicenses -WorkSheet $workBookDst.Worksheets.Item("Sheet10") -SheetName "licenses" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcFolders -WorkSheet $workBookDst.Worksheets.Item("Sheet11") -SheetName "folders" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcClusters -WorkSheet $workBookDst.Worksheets.Item("Sheet12") -SheetName "clusters" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcCertInfo -WorkSheet $workBookDst.Worksheets.Item("Sheet13") -SheetName "certs" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcAutoDepRules -WorkSheet $workBookDst.Worksheets.Item("Sheet14") -SheetName "autodeploy" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcADInfo -WorkSheet $workBookDst.Worksheets.Item("Sheet15") -SheetName "adinfo" -Excelpath $ExcelFilePathDst
    ConvertPSObjectToExcel -InputObject $SrcSummary -WorkSheet $workBookDst.Worksheets.Item("Sheet16") -SheetName "summary" -Excelpath $ExcelFilePathDst

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
	SaveToJson -InputObject $SrcADInfo -FileName "ad-info"
	SaveToJson -InputObject $SrcPlugins -FileName "plugins"
	SaveToJson -InputObject $SrcAutoDepRules -FileName "autodeploy-rules"
	SaveToJson -InputObject $SrcCertInfo -FileName "cert-info"
	SaveToJson -InputObject $SrcClusters -FileName "cluster-info"
	SaveToJson -InputObject $SrcFolders -FileName "folders"
	SaveToJson -InputObject $SrcPermissions -FileName "permissions"
	SaveToJson -InputObject $SrcOSCustomizations -FileName "os-customizations"
	SaveToJson -InputObject $SrcDeployments -FileName "deployments"
	SaveToJson -InputObject $SrcLicenses -FileName "licenses"
	SaveToJson -InputObject $SrcRoles -FileName "roles"
    SaveToJson -InputObject $SrcServices -FileName "services"
    SaveToJson -InputObject $SrcSites -FileName "sites"
    SaveToJson -InputObject $SrcVDSwitches -FileName "vdswitches"
    SaveToJson -InputObject $SrcVLANS -FileName "vlans"
    SaveToJson -InputObject $SrcSummary -FileName "summary"
}

### Save to Yaml
If ($Source -ne 3) {
	If (!(Test-Path -Path "$PSScriptRoot\Yaml")) {New-Item "$PSScriptRoot\Yaml" -Type Directory}
	SaveToYaml -InputObject $SrcADInfo -FileName "ad-info"
	SaveToYaml -InputObject $SrcPlugins -FileName "plugins"
	SaveToYaml -InputObject $SrcAutoDepRules -FileName "autodeploy-rules"
	SaveToYaml -InputObject $SrcCertInfo -FileName "cert-info"
	SaveToYaml -InputObject $SrcClusters -FileName "cluster-info"
	SaveToYaml -InputObject $SrcFolders -FileName "folders"
	SaveToYaml -InputObject $SrcPermissions -FileName "permissions"
	SaveToYaml -InputObject $SrcOSCustomizations -FileName "os-customizations"
	SaveToYaml -InputObject $SrcDeployments -FileName "deployments"
	SaveToYaml -InputObject $SrcLicenses -FileName "licenses"
	SaveToYaml -InputObject $SrcRoles -FileName "roles"
	SaveToYaml -InputObject $SrcServices -FileName "services"
	SaveToYaml -InputObject $SrcSites -FileName "sites"
	SaveToYaml -InputObject $SrcVDSwitches -FileName "vdswitches"
    SaveToYaml -InputObject $SrcVLANS -FileName "vlans"
    SaveToYaml -InputObject $SrcSummary -FileName "summary"
}

cls
#[System.GC]::Collect()
#[System.GC]::WaitForPendingFinalizers()

#https://social.technet.microsoft.com/Forums/scriptcenter/en-US/81dcbbd7-f6cc-47ec-8537-db23e5ae5e2f/excel-releasecomobject-doesnt-work?forum=ITCG
#[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($range)