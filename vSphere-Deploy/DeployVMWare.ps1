<#
.SYNOPSIS
   The script creates and configures a complete vSphere environment based on setting in a multi-tab excel file.
.DESCRIPTION
   Functionality:
   1. Deploy multiple vcsa from ovf.
	  a. Deployments can be any supported e.g. PSC, vCenter, Stand alone, Combined, etc.
	  b. Can be deployed to different networks and different hosts.
	  c. Supports different disk modes e.g. thin, thick, thick eager zero.
   2. Configurations
	  a. Join to a windows domain.
	  b. Set windows domain as primary identity source.
	  c. Add windows group as Administrative group to PSC.
	  d. Create Datacenters.
	  e. Create Folders.
	  f. Create Roles.
	  g. Create Permissions.
	  h. Create vdSwitches.
	  i. Create Port Groups/VLANs
	  j. Create OS customizations.
	  k. Create and Replace Certs from an external windows CA for:
		 i.   VCSA Machine Cert.
		 ii.  vmdir Cert.
		 iii. Solution User Certs.
	  i. Configure Services for Autdeploy, Network Dump, and TFTP.
	  j. Add licenses and assign licenses.
	  k. Import VMHost Profile and set VMHost Profile Root Password.
	  l. Configure Autodeploy Rules.
	  m. Create and add Public/Private Certificates for ssh authentication without passwords.

	To be done:
	1. Reconfigure vdswitch creation for full flexibility.
	2. Test and add functionality for multi part certificate replacement.
	3. Create certificates for Load Balancers.
	4. Test VMCA certificate deployment.
	5. Test various other configurations of deployment.
	6. Add prompt for credentials instead of reading from Excel?

.PARAMETER
   None.
.EXAMPLE
   <An example of using the script>
.REQUIREMENTS
	Programs:
		1. OpenSSL 1.0.2h x64 - C:\OpenSSL-Win64
		2. Ovftool 4.0.1
		3. Excel 2010+
		4. Internet Explorer
		5. Powershell 3+
		6. PowerCli 5.8+
		7. yaml for powershell plugin.

	Other:
		1. The Certificate templates for VMWare must be created on the Windows CA before running the script.
		2. vsphere-config.xlsx file.
		3. vmware-vcsa file from the vcsa iso.
		4. DNS entries for the vcsas must be added before runing the script.

.SOURCES
	http://www.derekseaman.com/2015/02/vsphere-6-0-install-pt-1-introduction.html
	http://orchestration.io/2014/05/19/using-powercli-and-ovftool-to-move-vms-between-vcenters/
	https://community.whatsupgold.com/library/powershellscripts/http_status_code_check_with_powershell
	http://huddledmasses.org/blog/validating-self-signed-certificates-properly-from-powershell/
	http://www.lazywinadmin.com/2014/03/powershell-read-excel-file-using-com.html
	https://github.com/lamw/vghetto-scripts/blob/master/shell/deploy_vcsa6_replicated_psc_to_vc.sh
	http://www.kanap.net/2014/12/vcsa-vcenter-server-appliance-part-4-deploy-ca-signed-certificates/
	https://myvirtualife.net/2015/01/21/vsphere-6-certificate-lifecycle-management/
	http://www.definit.co.uk/2015/07/vsphere-6-ha-sso-psc-with-netscaler-vpx-load-balancer-for-vrealize-automation/
	http://wojcieh.net/vcenter-server-6-replacing-ssl-certificates-with-custom-vmca/
	https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2111219
	http://blog.cloudinfra.info/vmware/vsphere-6-0-install-12-psc-machine-certificate/
	https://haveyoutriedreinstalling.com/2016/03/25/caution-solution-user-certificates-in-vsphere-6-0/
	http://www.vhersey.com/2011/11/powercli-to-check-for-vmware-toolsok/
	https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2116018
	http://grokthecloud.com/vcsa-tftp-server/
	http://www.vmwarebits.com/content/enable-tftp-service-and-firewall-rules-vcenter-6-appliance-autodeploy-and-make-them
	https://communities.vmware.com/thread/545899?sr=inbox
	http://www.lucd.info/2012/01/15/change-theroot-password-in-hosts-and-host-profiles/
	http://www.vtagion.com/adding-license-keys-vcenter-powercli/
	https://virtualhobbit.com/2015/07/17/building-an-advanced-lab-using-vmware-vrealize-automation-part-6-deploy-and-configure-the-vcenter-server-appliance/
	https://blogs.vmware.com/vsphere/2016/11/getting-started-new-image-builder-gui-vsphere-6-5.html
	http://thecloudxpert.net/vmware/vmware-psc-an-identity-source-for-vrealize-automation-6-x/
	https://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2121701
	https://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2121689
	https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988
	https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable

.ACKNOWLEDGEMENTS
	I'd like to thank the following people who's blogs/scripts/help/moral support/etc. I used in to create this script.

	1.  Derek Seamans			- www.derekseaman.com
	2.  William Lam				- www.virtuallyghetto.com
	3.  Chris Greene			- orchestration.io
	4.  RJ Davis				- community.whatsupgold.com
	5.  Joel "Jaykul" Bennett 	- huddledmasses.org/
	6.  Francois-Xavier Cat 	- www.lazywinadmin.com/
	7.  Friedrich Eva			- www.kanap.net/
	8.  Andrea Casin			- myvirtualife.net
	9.  Sam McGeown				- www.definit.co.uk
	10. Wojciech Marusiak		- wojcieh.net
	11. blog.cloudinfra.info
	12. F�idhlim O'Leary		- haveyoutriedreinstalling.com
	13. Alan Renouf				- www.virtu-al.net
	14. Jeramiah Dooley			- Netapp
	15. Aaron Patten			- Netapp
	16. VMWare Support
	17. John Dwyer				- grokthecloud.com
	18. Rob Bastiaansen 		- www.vmwarebits.com
	19.	Luc Deneks				- communities.vmware.com/people/LucD and www.lucd.info
	20. Brian Graf				- www.vtagion.com
	21. Mark Brookfield			- vitualhobbit.com
	22. Eric Gray				- blogs.vmware.com
	23. Christopher Lewis		- thecloudxpert.net
	24. Dave Wyatt				- StackOverflow

.AUTHOR
    Michael van Blijdesteijn
    Last Updated: 10-24-2019
#>

# Check to see if the url is Get-URLStatus.
Param([Parameter(Mandatory=$false)]
		[ValidateSet("excel","json","yaml")]
		[string]$Source = "excel",
    	[Parameter(Mandatory=$false)]
		[switch]$Export,
    	[Parameter(Mandatory=$false)]
    	[string]$FilePath
)

#Get public and private function definition files.
$certFunctions  = @( Get-ChildItem -Path $PSScriptRoot\Certificate\*.ps1 -ErrorAction SilentlyContinue )
$privateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($certFunctions + $privateFunctions))
{
    Try {
        Write-Verbose "Importing $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Clear the screen.
Clear-Host

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook
$excelFileName = "vsphere-configs.xlsx"

if (-not $FilePath) {$folderPath = $pwd.path.ToString()}

if ($Source -eq "excel" -and $FilePath) {
    $excelFileName  = $FilePath.Split("\")[$FilePath.Split("\").count -1]
    $folderPath     = $FilePath.Substring(0,$FilePath.Lastindexof("\"))
}

# PSScriptRoot does not have a trailing "\"
Write-Output $folderPath | Out-String

# Start New Transcript
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Continue"
$logPath = "$folderPath\Logs\" + $(Get-Date -format "MM-dd-yyyy_HH-mm")
if (-not(Test-Path $logPath)) {
	New-Item $logPath -Type Directory
}
$OutputPath = "$logPath\InitialState_" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
Start-Transcript -path $OutputPath -append

Write-SeparatorLine

# Check to see if Powershell is at least version 3.0
$PSPath = "HKLM:\SOFTWARE\Microsoft\PowerShell\3"
if (-not(Test-Path $PSPath)) {
	Write-Host "PowerShell 3.0 or higher required. Please install"; Exit
}

# Load Powercli Modules
if (Get-Module -ListGet-URLStatus | Where-Object {$_.Name -match "VMware.PowerCLI"}) {
	Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue
} else {
	if (Get-Command Install-Module -ErrorAction SilentlyContinue) {
			Install-Module -Name VMware.PowerCLI -Confirm:$false
	} else {
		exit
	}
}

if (Get-Module -ListGet-URLStatus | Where-Object {$_.Name -match "powershell-yaml"}) {
	Import-Module powershell-yaml -ErrorAction SilentlyContinue
} else {
	if (Get-Command Install-Module -ErrorAction SilentlyContinue) {
		Install-Module -Name powershell-yaml -Confirm:$false
	} else {
		exit
	}
}

Write-SeparatorLine

# Check the version of Ovftool and get it's path. Search C:\program files\ and C:\Program Files (x86)\ subfolders for vmware and find the
# Ovftool folders. Then check the version and return the first one that is version 4 or higher.
$OvfToolPath = (Get-ChildItem (Get-ChildItem $env:ProgramFiles, ${env:ProgramFiles(x86)} -filter vmware).fullname -recurse -filter ovftool.exe | ForEach-Object {if (-not((& $($_.DirectoryName + "\ovftool.exe") --version).Split(" ")[2] -lt 4.0.0)) {$_}} | Select-Object -first 1).DirectoryName

# Check ovftool version
if (-not $OvfToolPath) {
	Write-Host "Script requires installation of ovftool 4.0.0 or newer";
	exit
} else {
	Write-Host "ovftool version OK `r`n"
}

# ---------------------  Load Parameters from Excel ------------------------------

### Load from Excel
switch ($Source) {
	'excel' {
			Import-Module -Name pwshExcel
			# Source Excel Path
			$ExcelFilePathSrc = "$folderPath\$excelFileName"
			$configData = Import-ExcelData -Path $ExcelFilePathSrc
		}

	'json' {
			$Json_Dir = $folderPath + "\Json"
			$ADInfo				= Get-Content -Raw -Path "$Json_Dir\ad-info.json" 			| ConvertFrom-Json
			$Plugins			= Get-Content -Raw -Path "$Json_Dir\plugins.json"			| ConvertFrom-Json
			$AutoDepRules		= Get-Content -Raw -Path "$Json_Dir\autodeploy-rules.json"	| ConvertFrom-Json
			$CertInfo			= Get-Content -Raw -Path "$Json_Dir\cert-info.json"			| ConvertFrom-Json
			$Clusters			= Get-Content -Raw -Path "$Json_Dir\cluster-info.json"		| ConvertFrom-Json
			$Folders			= Get-Content -Raw -Path "$Json_Dir\folders.json"			| ConvertFrom-Json
			$Permissions		= Get-Content -Raw -Path "$Json_Dir\permissions.json"		| ConvertFrom-Json
			$OSCustomizations	= Get-Content -Raw -Path "$Json_Dir\os-customizations.json"	| ConvertFrom-Json
			$Deployments		= Get-Content -Raw -Path "$Json_Dir\deployments.json"		| ConvertFrom-Json
			$Licenses			= Get-Content -Raw -Path "$Json_Dir\licenses.json"			| ConvertFrom-Json
			$Roles				= Get-Content -Raw -Path "$Json_Dir\roles.json"				| ConvertFrom-Json
			$Services			= Get-Content -Raw -Path "$Json_Dir\services.json"			| ConvertFrom-Json
			$Sites				= Get-Content -Raw -Path "$Json_Dir\sites.json"				| ConvertFrom-Json
			$VDSwitches			= Get-Content -Raw -Path "$Json_Dir\vdswitches.json"		| ConvertFrom-Json
			$VLANS				= Get-Content -Raw -Path "$Json_Dir\vlans.json"				| ConvertFrom-Json
			$Summary      	    = Get-Content -Raw -Path "$Json_Dir\summary.json"			| ConvertFrom-Json
			$configData = @($ADInfo,$Plugins,$AutoDepRules,$CertInfo,$Clusters,$Folders,$Permissions,$OSCustomizations, `
				$Deployments,$Licenses,$Roles,$Services,$Sites,$VDSwitches,$VLANS,$Summary)
		}

	'yaml' {
			$Yaml_Dir = $folderPath + "\Yaml"
			$ADInfo				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\ad-info.yml" 	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Plugins			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\plugins.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$AutoDepRules		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\autodeploy-rules.yml"  | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$CertInfo			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cert-info.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Clusters			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cluster-info.yml"      | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Folders			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\folders.yml"	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Permissions		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\permissions.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$OSCustomizations	= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\os-customizations.yml"	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Deployments		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\deployments.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Licenses			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\licenses.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Roles				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\roles.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Services			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\services.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Sites				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\sites.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$VDSwitches			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vdswitches.yml"  		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$VLANS				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vlans.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$Summary         	= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\summary.yml"	    	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)

            # Change ":" Colon to commas for Vlan Network Properties.
			for ($i=0;$i -lt ($VLANS | Measure-Object).count;$i++) {
				$VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
			}

			$configData = @($ADInfo,$Plugins,$AutoDepRules,$CertInfo,$Clusters,$Folders,$Permissions,$OSCustomizations, `
				$Deployments,$Licenses,$Roles,$Services,$Sites,$VDSwitches,$VLANS,$Summary)
		}
}

Write-Output $configData.ADInfo				| Out-String
Write-SeparatorLine
Write-Output $configData.Plugins			| Out-String
Write-SeparatorLine
Write-Output $configData.AutoDepRules		| Out-String
Write-SeparatorLine
Write-Output $configData.CertInfo			| Out-String
Write-SeparatorLine
Write-Output $configData.Clusters			| Out-String
Write-SeparatorLine
Write-Output $configData.Folders			| Out-String
Write-SeparatorLine
Write-Output $configData.Permissions		| Out-String
Write-SeparatorLine
Write-Output $configData.OSCustomizations	| Out-String
Write-SeparatorLine
Write-Output $configData.Deployments		| Out-String
Write-SeparatorLine
Write-Output $configData.Licenses			| Out-String
Write-SeparatorLine
Write-Output $configData.Roles				| Out-String
Write-SeparatorLine
Write-Output $configData.Services			| Out-String
Write-SeparatorLine
Write-Output $configData.Sites				| Out-String
Write-SeparatorLine
Write-Output $configData.VDSwitches			| Out-String
Write-SeparatorLine
Write-Output $configData.VLANS				| Out-String
Write-SeparatorLine
Write-Output $configData.Summary			| Out-String
Write-SeparatorLine

# Password Scrub array for redacting passwords from Transcript.
if ($configData.Summary.TranscriptScrub) {
    $Scrub = @()
    $Scrub += $configData.ADInfo.ADJoinPass
    $Scrub += $configData.ADInfo.ADvmcamPass
    $Scrub += $configData.AutoDepRules.ProfileRootPassword
	$Scrub += $configData.OSCustomizations.AdminPassword
	$Scrub += $configData.OSCustomizations.DomainPassword
    $Scrub += $configData.Deployments.VCSARootPass
    $Scrub += $configData.Deployments.esxiRootPass
    $Scrub += $configData.Deployments.SSOAdminPass
}

### Save to Excel
if ($Source -ne 1 -and $Export) {
	$ExcelFilePathDst = "$folderPath\$excelFileName"
	if (Test-Path -Path $ExcelFilePathDst) {Remove-Item -Path $ExcelFilePathDst -Confirm:$false -Force}

	$ObjExcelDst = New-Object -ComObject Excel.Application
	$ObjExcelDst.Visible = $false
	$WorkBookDst = $ObjExcelDst.Workbooks.Add()
	$WorkSheetcount = 16 - ($WorkBookDst.worksheets | measure-object).count

	# http://www.planetcobalt.net/sdb/vba2psh.shtml
	$def = [Type]::Missing
	$null = $ObjExcelDst.Worksheets.Add($def,$def,$WorkSheetcount,$def)

	ConvertTo-Excel -InputObject $configData.VLANS -WorkSheet $WorkBookDst.Worksheets.Item("Sheet3") -SheetName "vlans" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.VDSwitches -WorkSheet $WorkBookDst.Worksheets.Item("Sheet2") -SheetName "vdswitches" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Deployments-WorkSheet $WorkBookDst.Worksheets.Item("Sheet1") -SheetName "vcsa" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Sites -WorkSheet $WorkBookDst.Worksheets.Item("Sheet4") -SheetName "sites" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Services -WorkSheet $WorkBookDst.Worksheets.Item("Sheet5") -SheetName "services" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Roles -WorkSheet $WorkBookDst.Worksheets.Item("Sheet6") -SheetName "roles" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Plugins -WorkSheet $WorkBookDst.Worksheets.Item("Sheet7") -SheetName "plugins" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Permissions -WorkSheet $WorkBookDst.Worksheets.Item("Sheet8") -SheetName "permissions" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.OSCustomizations -WorkSheet $WorkBookDst.Worksheets.Item("Sheet9") -SheetName "OS" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Licenses -WorkSheet $WorkBookDst.Worksheets.Item("Sheet10") -SheetName "licenses" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Folders -WorkSheet $WorkBookDst.Worksheets.Item("Sheet11") -SheetName "folders" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.Clusters -WorkSheet $WorkBookDst.Worksheets.Item("Sheet12") -SheetName "clusters" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.CertInfo -WorkSheet $WorkBookDst.Worksheets.Item("Sheet13") -SheetName "certs" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.AutoDepRules -WorkSheet $WorkBookDst.Worksheets.Item("Sheet14") -SheetName "autodeploy" -Excelpath $ExcelFilePathDst
	ConvertTo-Excel -InputObject $configData.ADInfo -WorkSheet $WorkBookDst.Worksheets.Item("Sheet15") -SheetName "adinfo" -Excelpath $ExcelFilePathDst
    ConvertTo-Excel -InputObject $configData.Summary -WorkSheet $WorkBookDst.Worksheets.Item("Sheet16") -SheetName "summary" -Excelpath $ExcelFilePathDst

	$ObjExcelDst.DisplayAlerts = $False
	$ObjExcelDst.ActiveWorkbook.SaveAs($ExcelFilePathDst,$xlFixedFormat,1)
	$WorkBookDst.Close($false)
	$ObjExcelDst.Quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()

	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($WorkBookDst)
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ObjExcelDst)
}

### Save to Json
if ($Source -ne 2 -and $Export) {
	if (-not(Test-Path -Path "$folderPath\Json")) {
		New-Item "$folderPath\Json" -Type Directory
	}
	Save-Json -InputObject $configData.ADInfo -FilePath "$folderPath\ad-info.json"
	Save-Json -InputObject $configData.Plugins -FilePath "$folderPath\plugins.json"
	Save-Json -InputObject $configData.AutoDepRules -FilePath "$folderPath\autodeploy-rules.json"
	Save-Json -InputObject $configData.CertInfo -FilePath "$folderPath\cert-info.json"
	Save-Json -InputObject $configData.Clusters -FilePath "$folderPath\cluster-info.json"
	Save-Json -InputObject $configData.Folders -FilePath "$folderPath\folders.json"
	Save-Json -InputObject $configData.Permissions -FilePath "$folderPath\permissions.json"
	Save-Json -InputObject $configData.OSCustomizations -FilePath "$folderPath\os-customizations.json"
	Save-Json -InputObject $configData.Deployments-FilePath "$folderPath\deployments.json"
	Save-Json -InputObject $configData.Licenses -FilePath "$folderPath\licenses.json"
	Save-Json -InputObject $configData.Roles -FilePath "$folderPath\roles.json"
    Save-Json -InputObject $configData.Services -FilePath "$folderPath\services.json"
    Save-Json -InputObject $configData.Sites -FilePath "$folderPath\sites.json"
    Save-Json -InputObject $configData.VDSwitches -FilePath "$folderPath\vdswitches.json"
    Save-Json -InputObject $configData.VLANS -FilePath "$folderPath\vlans.json"
    Save-Json -InputObject $configData.Summary -FilePath "$folderPath\summary.json"
}

### Save to Yaml
if ($Source -ne 3 -and $Export) {
	if (-not(Test-Path -Path "$folderPath\Yaml")) {
		New-Item "$folderPath\Yaml" -Type Directory
	}
	Save-Yaml -InputObject $configData.ADInfo -FilePath "$folderPath\ad-info.yml"
	Save-Yaml -InputObject $configData.Plugins -FilePath "$folderPath\plugins.yml"
	Save-Yaml -InputObject $configData.AutoDepRules -FilePath "$folderPath\autodeploy-rules.yml"
	Save-Yaml -InputObject $configData.CertInfo -FilePath "$folderPath\cert-info.yml"
	Save-Yaml -InputObject $configData.Clusters -FilePath "$folderPath\cluster-info.yml"
	Save-Yaml -InputObject $configData.Folders -FilePath "$folderPath\folders.yml"
	Save-Yaml -InputObject $configData.Permissions -FilePath "$folderPath\permissions.yml"
	Save-Yaml -InputObject $configData.OSCustomizations -FilePath "$folderPath\os-customizations.yml"
	Save-Yaml -InputObject $configData.Deployments-FilePath "$folderPath\deployments.yml"
	Save-Yaml -InputObject $configData.Licenses -FilePath "$folderPath\licenses.yml"
	Save-Yaml -InputObject $configData.Roles -FilePath "$folderPath\roles.yml"
	Save-Yaml -InputObject $configData.Services -FilePath "$folderPath\services.yml"
	Save-Yaml -InputObject $configData.Sites -FilePath "$folderPath\sites.yml"
	Save-Yaml -InputObject $configData.VDSwitches -FilePath "$folderPath\vdswitches.yml"

    # Change commas to ":" Colon for Vlan Network Properties.
	for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
		$configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ",",':'; $_.value = $commacorrect}}
	}

	Save-Yaml -InputObject $configData.VLANS -FilePath "$folderPath\vlans.yml"

    # Change ":" Colon to commas for Vlan Network Properties.
	for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
		$configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
	}

    Save-Yaml -InputObject $configData.Summary -FilePath "$folderPath\summary.yml"
}

Add-Null $configData.ADInfo
Add-Null $configData.Plugins
Add-Null $configData.AutoDepRules
Add-Null $configData.CertInfo
Add-Null $configData.Clusters
Add-Null $configData.Folders
Add-Null $configData.Permissions
Add-Null $configData.OSCustomizations
Add-Null $configData.Deployments
Add-Null $configData.Licenses
Add-Null $configData.Roles
Add-Null $configData.Services
Add-Null $configData.Sites
Add-Null $configData.VDSwitches
Add-Null $configData.VLANS
Add-Null $configData.Summary

# ---------------------  END Load Parameters from Excel ------------------------------

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

# Download OpenSSL if it's not already installed
if (-not($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"})) {
	$uri = "https://slproweb.com/products/Win32OpenSSL.html"
	$downloadRef = ((Invoke-WebRequest -uri $uri).Links | Where-Object {$_.outerHTML -like "*Win64OpenSSL_*"} | Select-Object -first 1).href.Split("/")[2]
	Write-Host -Foreground "DarkBlue" -Background "White" "Downloading OpenSSL $downloadRef ..."
	$null = New-Item -Type Directory $configData.CertInfo[0].openssldir -erroraction silentlycontinue
	$SSLUrl = "http://slproweb.com/download/$downloadRef"
	$SSLExe = "$env:temp\openssl.exe"
	$WC 							= New-Object System.Net.WebClient
	$WC.UseDefaultCredentials 		= $true
	$WC.DownloadFile($SSLUrl,$SSLExe)
	$env:path = $env:path + ";$($configData.CertInfo[0].openssldir)"
    if (-not(test-Path($SSLExe))) {
		Write-Host -Foreground "red" -Background "white" "Could not download or find OpenSSL. Please install the latest $downloadRef manually or update download name."
		exit
	}
	Write-Host -Foreground "DarkBlue" -Background "White" "Installing OpenSSL..."
    cmd /c $SSLExe /DIR="$($configData.CertInfo[0].openssldir)" /silent /verysilent /sp- /suppressmsgboxes
	Remove-Item $SSLExe
}

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

$OpenSSL = ($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"}).InstallLocation + "bin\openssl.exe"

# Check for openssl
Test-OpenSSL $OpenSSL

Write-SeparatorLine

# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
$NetAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

if ($NetAssembly) {
    $BindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
    $SettingsType = $NetAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

    $Instance = $SettingsType.InvokeMember("Section", $BindingFlags, $null, $null, @())

    if ($Instance) {
        $BindingFlags = "NonPublic","Instance"
        $UseUnsafeHeaderParsingField = $SettingsType.GetField("useUnsafeHeaderParsing", $BindingFlags)

        if ($UseUnsafeHeaderParsingField) {
          $UseUnsafeHeaderParsingField.SetValue($Instance, $true)
        }
    }
}

# Global variables
$pscDeployments	= @("tiny","small","medium","large","infrastructure")

# Certificate variables
# Create the RANDFILE environmental parameter for openssl to fuction properly.
$env:RANDFILE = "$folderPath\Certs\.rnd"

$script:CertsWaitingForApproval = $false
New-Alias -Name OpenSSL $OpenSSL

Stop-Transcript

# Deploy the VCSA servers.
foreach ($Deployment in $configData.Deployments| Where-Object {$_.Action}) {
	# Skip deployment if set to null.

	$OutputPath = "$logPath\Deploy-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting deployment of $($Deployment.vmName) ===============" | Out-String

	# Deploy the vcsa
	New-VCSADeploy $Deployment $OvfToolPath $logPath

	# Write separator line to transcript.
	Write-SeparatorLine

	# Create esxi credentials.
	$ESXiSecPasswd		= $null
	$ESXiCreds			= $null
	$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

	# Connect to esxi host of the deployed vcsa.
	$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

	Write-SeparatorLine

	$script = 'find /var/log/firstboot/ -type f \( -name "succeeded" -o -name "failed" \)'

	Write-Output "== Firstboot process could take 10+ minutes to complete. please wait. ==" | Out-String

	if (-not $StopWatch) {
		$StopWatch =  [system.diagnostics.stopwatch]::StartNew()
	} else {
		$StopWatch.start()
	}

	$Firstboot = (Invoke-ExecuteScript $script $Deployment.Hostname "root" $($Deployment.VCSARootPass) $ESXiHandle).ScriptOutput

	While (-not $Firstboot) {

	  	Start-Sleep -s 15

	  	$Elapsed = $StopWatch.Elapsed.ToString('hh\:mm\:ss')

		Write-Progress -Activity "Completing Firstboot for $($Deployment.Hostname)" -Status "Time Elapsed $Elapsed"

		Write-Output "Time Elapsed completing Firstboot for $($Deployment.Hostname): $Elapsed" | Out-String

		$Firstboot = (Invoke-ExecuteScript $script $Deployment.Hostname "root" $($Deployment.VCSARootPass) $ESXiHandle).ScriptOutput
	}

	$StopWatch.reset()

	if ($Firstboot -like "*failed*") {
		Write-Output "Deployment of " + $Deployment.Hostname + " Failed. Exiting Script." | Out-String
		break
	}

    # Enable Jumbo Frames on eth0 if True.
    if ($Deployment.JumboFrames) {
        $commandList = $null
	    $commandList = @()
		$commandList += 'echo -e "" >> /etc/systemd/network/10-eth0.network'
		$commandList += 'echo -e "[Link]" >> /etc/systemd/network/10-eth0.network'
	    $commandList += 'echo -e "MTUBytes=9000" >> /etc/systemd/network/10-eth0.network'

        Invoke-ExecuteScript $commandList $Deployment.vmName "root" $Deployment.VCSARootPass $ESXiHandle
    }

	Write-Output "`r`n The VCSA $($Deployment.Hostname) has been deployed and is Get-URLStatus.`r`n" | Out-String

	# Create certificate directory if it does not exist
	$CertDir			= $folderPath + "\Certs\" + $Deployment.SSODomainName
	$DefaultRootCertDir = $CertDir + "\" + $Deployment.Hostname + "\DefaultRootCert"

	if (-not(Test-Path $DefaultRootCertDir)) {
		New-Item $DefaultRootCertDir -Type Directory | Out-Null
	}

	Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

	New-CertificatePair $CertDir $Deployment $ESXiHandle

    # Import the vCenter self signed certificate into the local trusted root certificate store.
	Import-HostRootCertificate $DefaultRootCertDir $Deployment $ESXiHandle

	# Disconnect from the vcsa deployed esxi server.
	DisConnect-VIServer -Server $ESXiHandle -Confirm:$false

	# Write separator line to transcript.
	Write-SeparatorLine

	Write-Host "=============== End of Deployment for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

# Replace Certificates.
foreach ($Deployment in $configData.Deployments| Where-Object {$_.Certs}) {

	$OutputPath = "$logPath\Certs-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting replacement of Certs on $($Deployment.vmName) ===============" | Out-String

	# Wait until the vcsa is Get-URLStatus.
	Get-URLStatus $("https://" + $Deployment.Hostname)

	# Set $CertDir
	$CertDir 		= $folderPath + "\Certs\" + $Deployment.SSODomainName
	$RootCertDir	= $CertDir + "\" + $Deployment.Hostname

	# Create certificate directory if it does not exist
	if (-not(Test-Path $RootCertDir)) {
		New-Item $RootCertDir -Type Directory | Out-Null
	}

	$configData.Certs = $configData.CertInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}

	Write-Output $configData.Certs | Out-String

	if ($configData.Certs) {
		# Create esxi credentials.
        $ESXiSecPasswd		= $null
		$ESXiCreds			= $null
		$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
		$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

		# Connect to esxi host of the deployed vcsa.
		$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

		# Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
		$configData.Certs.CompanyName = $Deployment.Hostname

		# $InstanceCertDir is the script location plus cert folder and Hostname eg. C:\Script\Certs\SSODomain\vm-host1.companyname.com\
		$InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

		# Check for or download root certificates.
		Import-RootCertificate $RootCertDir	$configData.Certs

		# Create the Machine cert.
		New-CSR machine machine_ssl.csr machine_ssl.cfg ssl_key.priv 6 $InstanceCertDir $configData.Certs
		Invoke-CertificateMint machine machine_ssl.csr new_machine.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
		ConvertTo-PEMFormat machine new_machine.crt new_machine.cer $RootCertDir $InstanceCertDir

		# Change back to the script root folder.
		Set-Location $folderPath

		# Create the VMDir cert.
		New-CSR VMDir VMDir.csr VMDir.cfg VMDir.priv 6 $InstanceCertDir $configData.Certs
		Invoke-CertificateMint VMDir VMDir.csr VMDir.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
		ConvertTo-PEMFormat VMDir VMDir.crt VMdir.cer $RootCertDir $InstanceCertDir

		# Rename the VMDir cert for use on a VMSA.
		Rename-VMDir $InstanceCertDir

		# Change back to the script root folder.
		Set-Location $folderPath

        $SSOParent = $null
        $SSOParent = $configData.Deployments| Where-Object {$Deployment.Parent -eq $_.Hostname}

		# Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
		if ($Deployment.DeployType -eq "infrastructure" ) {

			New-SolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $configData.Certs
			New-SolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $configData.Certs

			Invoke-CertificateMint Solution machine.csr machine.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
			Invoke-CertificateMint Solution vsphere-webclient.csr vsphere-webclient.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA

			ConvertTo-PEMFormat Solution machine.crt machine.cer $RootCertDir $InstanceCertDir
			ConvertTo-PEMFormat Solution vsphere-webclient.crt vsphere-webclient.cer $RootCertDir $InstanceCertDir

			Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            Copy-CertificateToHost $RootCertDir $CertDir $Deployment $ESXiHandle $SSOParent
		} else {
			New-SolutionCSR Solution vpxd.csr vpxd.cfg vpxd.priv 6 vpxd $InstanceCertDir $configData.Certs
			New-SolutionCSR Solution vpxd-extension.csr vpxd-extension.cfg vpxd-extension.priv 6 vpxd-extension $InstanceCertDir $configData.Certs
			New-SolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $configData.Certs
			New-SolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $configData.Certs

			Invoke-CertificateMint Solution vpxd.csr vpxd.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
			Invoke-CertificateMint Solution vpxd-extension.csr vpxd-extension.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
			Invoke-CertificateMint Solution machine.csr machine.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
			Invoke-CertificateMint Solution vsphere-webclient.csr vsphere-webclient.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA

			ConvertTo-PEMFormat Solution vpxd.crt vpxd.cer $RootCertDir $InstanceCertDir
			ConvertTo-PEMFormat Solution vpxd-extension.crt vpxd-extension.cer $RootCertDir $InstanceCertDir
			ConvertTo-PEMFormat Solution machine.crt machine.cer $RootCertDir $InstanceCertDir
			ConvertTo-PEMFormat Solution vsphere-webclient.crt vsphere-webclient.cer $RootCertDir $InstanceCertDir

			Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            Copy-CertificateToHost $RootCertDir $CertDir $Deployment $ESXiHandle $SSOParent
			# Configure Autodeploy and replace the solution user certificates, and update the thumbprint to the new machine ssl thumbprint.
			# https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988
            if (($configData.Services | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AutoDeploy"}).Service) {
				$commandList = $null
				$commandList = @()
				# Set path for python.
				$commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				$commandList += "export VMWARE_LOG_DIR=/var/log"
				$commandList += "export VMWARE_CFG_DIR=/etc/vmware"
				$commandList += "export VMWARE_DATA_DIR=/storage"
				# Configure Autodeploy to automatic start and start the service.
				$commandList += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
 				$commandList += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"
				# Replace the solution user cert for Autodeploy.
				$commandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.Hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				# Configure imagebuilder and start the service.
				$commandList += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
				$commandList += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"
				# Replace the imagebuilder solution user cert.
				$commandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.imagebuilder -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.Hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle

				# Get the new machine cert thumbprint.
				$commandList = $null
				$commandList = @()
				$commandList += "openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint"
				$newthumbprint = $(Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle).Scriptoutput.Split("=",2)[1]
				$newthumbprint = $newthumbprint -replace "`t|`n|`r",""
				# Replace the autodeploy cert thumbprint.
				$commandList = $null
				$commandList = @()
				# Set path for python.
				$commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				$commandList += "export VMWARE_LOG_DIR=/var/log"
				$commandList += "export VMWARE_CFG_DIR=/etc/vmware"
				$commandList += "export VMWARE_DATA_DIR=/storage"
				# Stop the autodeploy service.
				$commandList += "/usr/bin/service-control --stop vmware-rbd-watchdog"
				# Replace the thumbprint.
				$commandList += "autodeploy-register -R -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -s `"/etc/vmware-rbd/autodeploy-setup.xml`" -f -T $newthumbprint"
				# Start the autodeploy service.
				$commandList += "/usr/bin/service-control --start vmware-rbd-watchdog"
				Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
			}
			if (($configData.Services | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AuthProxy"}).Service) {
				# Create Authorization Proxy Server Certificates.
				New-CSR authproxy authproxy.csr authproxy.cfg authproxy.priv 6 $InstanceCertDir $configData.Certs
				Invoke-CertificateMint authproxy authproxy.csr authproxy.crt $configData.Certs.V6Template $InstanceCertDir $configData.Certs.IssuingCA
				# Copy the Authorization Proxy Certs to the vCenter.
				$FileLocations = $null
				$FileLocations = @()
				$FileLocations += "$InstanceCertDir\authproxy\authproxy.priv"
				$FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.key"
				$FileLocations += "$InstanceCertDir\authproxy\authproxy.crt"
				$FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.crt"
				Copy-FileToServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle $true
				# Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
				$commandList = $null
				$commandList = @()
				$commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				$commandList += "export VMWARE_LOG_DIR=/var/log"
				$commandList += "export VMWARE_CFG_DIR=/etc/vmware"
				$commandList += "export VMWARE_DATA_DIR=/storage"
				$commandList += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
 				$commandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				$commandList += "/usr/lib/vmware-vmcam/bin/camregister --unregister -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`'"
				$commandList += "/usr/bin/service-control --stop vmcam"
				$commandList += "mv /var/lib/vmware/vmcam/ssl/rui.crt /var/lib/vmware/vmcam/ssl/rui.crt.bak"
				$commandList += "mv /var/lib/vmware/vmcam/ssl/rui.key /var/lib/vmware/vmcam/ssl/rui.key.bak"
				$commandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.crt /var/lib/vmware/vmcam/ssl/rui.crt"
				$commandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.key /var/lib/vmware/vmcam/ssl/rui.key"
				$commandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.crt"
				$commandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.key"
				$commandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				$commandList += "/usr/lib/vmware-vmcam/bin/camregister --register -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`' -c /var/lib/vmware/vmcam/ssl/rui.crt -k /var/lib/vmware/vmcam/ssl/rui.key"
				# Service update
				Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
			}

        }

        Write-SeparatorLine

        Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

        New-CertificatePair $CertDir $Deployment $ESXiHandle

		# Write separator line to transcript.
		Write-SeparatorLine

		# Delete all certificate files etc to clean up /root/ - exclude authorized_keys
		$commandList = $null
		$commandList = @()
		$commandList += 'rm /root/vcrootcert.crt'
		$commandList += 'rm -r /root/solutioncerts'
		$commandList += 'rm -r /root/ssl'
		$commandList += 'find /root/.ssh/ ! -name "authorized_keys" -type f -exec rm -rf {} \;'

		Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle

		Write-Host "=============== Restarting $($Deployment.vmName) ===============" | Out-String
		Restart-VMGuest -VM $Deployment.vmName -Server $ESXiHandle -Confirm:$false

		# Wait until the vcsa is Get-URLStatus.
		Get-URLStatus $("https://" + $Deployment.Hostname)

		Write-Host "=============== End of Certificate Replacement for $($Deployment.vmName) ===============" | Out-String

		# Disconnect from the vcsa deployed esxi server.
		DisConnect-VIServer -Server $ESXiHandle -Confirm:$false
	}

	Stop-Transcript
}

# Configure the vcsa.
foreach ($Deployment in $configData.Deployments| Where-Object {$_.Config}) {

	$OutputPath = "$logPath\Config-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	# Set $CertDir
	$CertDir 		= $folderPath + "\Certs\" + $Deployment.SSODomainName
	$RootCertDir	= $CertDir + "\" + $Deployment.Hostname

	# Create certificate directory if it does not exist
	if (-not(Test-Path $RootCertDir)) {
		New-Item $RootCertDir -Type Directory | Out-Null
	}

	Write-Output "=============== Starting configuration of $($Deployment.vmName) ===============" | Out-String

	Write-SeparatorLine

	# Wait until the vcsa is Get-URLStatus.
	Get-URLStatus $("https://" + $Deployment.Hostname)

	# Create esxi credentials.
    $ESXiSecPasswd		= $null
	$ESXiCreds			= $null
	$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

	# Connect to esxi host of the deployed vcsa.
	$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

	Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

	New-CertificatePair $CertDir $Deployment $ESXiHandle

	Write-SeparatorLine

	Write-Output $($configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($Deployment.Hostname)"}) | Out-String

    # Join the vcsa to the windows domain.
	Join-ADDomain $Deployment $($configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($Deployment.Hostname)"}) $ESXiHandle

	# if the vcsa is not a stand alone PSC, configure the vCenter.
	if ($Deployment.DeployType -ne "infrastructure" ) {

		Write-Output "== vCenter $($Deployment.vmName) configuration ==" | Out-String

		Write-SeparatorLine

		$Datacenters	= $configData.Sites | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
		$SSOSecPasswd	= ConvertTo-SecureString $($Deployment.SSOAdminPass) -AsPlainText -Force
		$SSOCreds		= New-Object System.Management.Automation.PSCredential ($("Administrator@" + $Deployment.SSODomainName), $SSOSecPasswd)

		# Connect to the vCenter
		$VCHandle = Connect-viserver $Deployment.Hostname -Credential $SSOCreds

		# Create Datacenter
		if ($Datacenters) {
			$Datacenters.Datacenter.ToUpper() | ForEach-Object {New-Datacenter -Location Datacenters -Name $_}
		}

		# Create Folders, Roles, and Permissions.
		$Folders = $configData.Folders | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
		if ($Folders) {
			Write-Output "Folders:" $Folders
			New-Folders $Folders $VCHandle
		}

		# if this is the first vCenter, create custom Roles.
		$existingroles = Get-VIRole -Server $VCHandle
		$Roles = $configData.Roles | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"} | Where-Object {$ExistingRoles -notcontains $_.Name}
           if ($Roles) {
			Write-Output  "Roles:" $Roles
			Add-Roles $Roles $VCHandle
		}

		# Create OS Customizations for the vCenter.
		$configData.OSCustomizations | Where-Object {$_.vCenter -eq $Deployment.Hostname} | ForEach-Object {ConvertTo-OSString $_}

		# Create Clusters
		foreach ($Datacenter in $Datacenters) {
			# Define IP Octets
			$Oct1 = $Datacenter.oct1
			$Oct2 = $Datacenter.oct2
			$Oct3 = $Datacenter.oct3

			# Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
               ($configData.Clusters | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)")`
                   -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}).Clustername |`
				ForEach-Object {if ($_) {New-Cluster -Location (Get-Datacenter -Server $VCHandle -Name $Datacenter.Datacenter) -Name $_}}

			# Create New vDSwitch
			# Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
			$VDSwitches = $configData.VDSwitches | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}

			foreach ($VDSwitch in $VDSwitches) {
				$SwitchDatacenter	= Get-Inventory -Name $Datacenter.Datacenter

				if ($VDSwitch.SwitchNumber.ToString().indexof(".") -eq -1) {
					$SwitchNumber = $VDSwitch.SwitchNumber.ToString() + ".0"
				} else {
					$SwitchNumber = $VDSwitch.SwitchNumber.ToString()
				}

				$SwitchName = $SwitchNumber + " " + $VDSwitch.vDSwitchName -replace "XXX", $Datacenter.Datacenter

                if ($VDSwitch.JumboFrames) {
					$mtu = 9000
				} else {
                    $mtu = 1500
                }

				# Create new vdswitch.
				New-VDSwitch -Server $VCHandle -Name $SwitchName -Location $SwitchDatacenter -Mtu $mtu -NumUplinkPorts 2 -Version $VDSwitch.Version

				# Enable NIOC
				(Get-vDSwitch -Server $VCHandle -Name $SwitchName | Get-View).EnableNetworkResourceManagement($true)

				$VLANAdd = $configData.VLANS | Where-Object {$_.Number.StartsWith($SwitchName.Split(" ")[0])}
				$VLANAdd = $VLANAdd	 | Where-Object {$_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)"}
				$VLANAdd = $VLANAdd  | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

				# Create Portgroups
				foreach ($VLAN in $VLANAdd) {

					$PortGroup =	$VLAN.Number.padright(8," ") +`
									$VLAN.Vlan.padright(8," ") + "- " +`
									$VLAN.Network.padright(19," ") + "- " +`
									$VLAN.VlanName

					$PortGroup = $PortGroup -replace "oct1", $Oct1
					$PortGroup = $PortGroup -replace "oct2", $Oct2
					$PortGroup = $PortGroup -replace "oct2", $Oct3

                    if ($PortGroup.Split("-")[0] -like "*trunk*") {
                        New-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.Split("-")[0] -VlanTrunkRange $VLAN.network
                    } else {
						New-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.Split("-")[0] -VlanId $VLAN.vlan.Split(" ")[1]
                    }
					# Set Portgroup Team policies
					if ($PortGroup -like "*vmotion-1*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
					}
					if ($PortGroup -like "*vmotion-2*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
					}
					if ($PortGroup -notlike "*vmotion*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
					} else {
						#Set Traffic Shaping on vmotion portgroups for egress traffic
						Get-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDTrafficShapingPolicy -Server $VCHandle -Direction Out| Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
					}
				}
			}
		}

		# Add Licenses to vCenter.
		if ($configData.Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) {
			Add-Licensing $($configData.Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $VCHandle
		}

		# Select permissions for all vCenters or the current vCenter.
		# Create the permissions.
		New-Permissions $($configData.Permissions | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}) $VCHandle

		$InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

		# Configure Additional Services (Network Dump, Autodeploy, TFTP)
		foreach ($Serv in $configData.Services) {
			Write-Output $Serv | Out-String
			if ($Serv.vCenter.Split(",") -match "all|$($Deployment.Hostname)") {
				switch ($Serv.Service) {
					AuthProxy	{ New-AuthProxyService $Deployment $ESXiHandle $($configData.ADInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}); break}
					AutoDeploy	{ $VCHandle | Get-AdvancedSetting -Name vpxd.certmgmt.certs.minutesBefore | Set-AdvancedSetting -Value 1 -Confirm:$false
								  New-AutoDeployService $Deployment $ESXiHandle
								  if ($configData.AutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) { New-AutoDeployRule $($configData.AutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $folderPath $VCHandle}
								  break
					}
					Netdumpster	{ New-NetDumpsterService $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle; break}
					TFTP		{ New-TFTPService $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle; break}
					default {break}
				}
			}
		}

        # Configure plugins
        $commandList = $null
        $commandList = @()
        $Plugins = $configData.Plugins | Where-Object {$_.config -and $_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

		Write-SeparatorLine
		Write-Output $Plugins | Out-String
		Write-SeparatorLine

        for ($i=0;$i -lt $Plugins.Count;$i++) {
        	if ($Plugins[$i].SourceDir) {
                if ($commandList) {
                    Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
                    $commandList = $null
                    $commandList = @()
                }
                $FileLocations = $null
                $FileLocations = @()
	            $FileLocations += "$($folderPath)\$($Plugins[$i].SourceDir)\$($Plugins[$i].SourceFiles)"
                $FileLocations += $Plugins[$i].DestDir
				Write-Output $FileLocations | Out-String
       	    	Copy-FileToServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle $true
            }
            if ($Plugins[$i].Command) {
				$commandList += $Plugins[$i].Command
			}
        }

        if ($commandList) {
			Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
		}

		Write-SeparatorLine

		Write-Output "Adding Build Cluster Alarm" | Out-String

		$DC = $Deployment.Hostname.Split(".")[1]

		$AlarmMgr = Get-View AlarmManager
		$entity = Get-Datacenter -Name $DC -server $VCHandle | Get-cluster "build" | Get-View

		# AlarmSpec
		$Alarm = New-Object VMware.Vim.AlarmSpec
		$Alarm.Name = "1. Configure New Esxi Host"
		$Alarm.Description = "Configure a New Esxi Host added to the vCenter"
		$Alarm.Enabled = $TRUE

		$Alarm.action = New-Object VMware.Vim.GroupAlarmAction

		$Trigger = New-Object VMware.Vim.AlarmTriggeringAction
		$Trigger.action = New-Object VMware.Vim.RunScriptAction
		$Trigger.action.Script = "/root/esxconf.sh {targetName}"

		# Transition a - yellow --> red
		$Transa = New-Object VMware.Vim.AlarmTriggeringActionTransitionSpec
		$Transa.StartState = "yellow"
		$Transa.FinalState = "red"

		$Trigger.TransitionSpecs = $Transa

		$Alarm.action = $Trigger

		$Expression = New-Object VMware.Vim.EventAlarmExpression
		$Expression.EventType = "EventEx"
		$Expression.eventTypeId = "vim.event.HostConnectedEvent"
		$Expression.objectType = "HostSystem"
		$Expression.status = "red"

		$Alarm.expression = New-Object VMware.Vim.OrAlarmExpression
		$Alarm.expression.expression = $Expression

		$Alarm.setting = New-Object VMware.Vim.AlarmSetting
		$Alarm.setting.reportingFrequency = 0
		$Alarm.setting.toleranceRange = 0

		# Create alarm.
		$AlarmMgr.CreateAlarm($entity.MoRef, $Alarm)

		# Disconnect from the vCenter.
		DisConnect-VIServer -server $VCHandle -Confirm:$false

		Write-SeparatorLine

	}

	# Run the vami_set_Hostname to set the correct FQDN in the /etc/hosts file on a vCenter with External PSC only.
	if ($Deployment.DeployType -like "*management*") {
		$commandList = $null
		$commandList = @()
		$commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$commandList += "export VMWARE_LOG_DIR=/var/log"
		$commandList += "export VMWARE_CFG_DIR=/etc/vmware"
		$commandList += "export VMWARE_DATA_DIR=/storage"
		$commandList += "/opt/vmware/share/vami/vami_set_hostname $($Deployment.Hostname)"

		Invoke-ExecuteScript $commandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
    }

	# Disconnect from the vcsa deployed esxi server.
	DisConnect-VIServer -Server $ESXiHandle -Confirm:$false

	Write-SeparatorLine

	Write-Host "=============== End of Configuration for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

Write-SeparatorLine

Write-Output "<=============== Deployment Complete ===============>" | Out-String

Set-Location -Path $folderPath

# Get Certificate folders that do not have a Date/Time in their name.
$CertFolders = (Get-Childitem -Path $($folderPath + "\Certs") -Directory).FullName | Where-Object {$_ -notmatch '\d\d-\d\d-\d\d\d\d'}

# Rename the folders to add Date/Time to the name.
$CertFolders | ForEach-Object {
	Rename-Item -Path $_ -NewName $($_ + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm"))
}

# Scrub logfiles
$LogFiles = (Get-ChildItem -Path $logPath).FullName

if ($configData.Summary.TranscriptScrub) {
    foreach ($Log in $LogFiles) {
        $Transcript = Get-Content -path $Log
	    foreach ($Pass in $Scrub) {
			$Transcript = $Transcript.replace($Pass,'<-- Password Redacted -->')
		}
    	$Transcript | Set-Content -path $Log -force -confirm:$false
    }
}