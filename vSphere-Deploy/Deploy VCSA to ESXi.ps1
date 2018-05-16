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
	Michael van Blijdesteijn - Highbridge Capital Management LLC.
	michael.vanblijdestein@highbridge.com

Functions Lines 192 - 1750
List:							Used:	function Dependency:
1.  Available					  Y
2. 	ConfigureAutoDeploy			  Y		ExecuteScript
3.	ConfigureAutoDeployRules	  Y		Set-VMHostProfileExtended
4.	ConfigureCertPairs			  Y		ExecuteScript, CopyFiletoServer
5. 	ConfigureIdentity			  Y		ExecuteScript
6. 	ConfigureLicensing			  Y
7. 	ConfigureNetdumpster		  Y		ExecuteScript
8. 	ConfigureTFTP				  Y		ExecuteScript
9.	ConvertPSObjectToExcel		  Y
10. ConvertPSObjectToHashtable	  Y
11. Deploy						  Y
12. CreateFolders				  Y		Separatorline
13. CreateRoles					  Y		Separatorline
14. CreatePermissions			  Y		Separatorline
15. ExecuteScript				  Y		Separatorline
16. CopyFiletoServer			  Y		Separatorline
17.	JoinADDomain				  Y		Available, ExecuteScript, Separatorline
18. OSString					  Y
19. RemoveNull					  Y
20. ReplaceNull					  Y
21. Separatorline				  Y
22. ChainCAs					  Y
23. CheckOpenSSL				  Y
24. CreatePEMFiles				  Y
25. CreateCSR					  Y
26. CreateSolutionCSR			  Y
27. CreateVMCACSR				  Y
28. DisplayVMDir				  Y
29. DownloadRoots				  Y
30. MoveUserCerts				  Y
31. OnlineMint					  Y
32. OnlineMintResume			  N
33.	SaveToYaml					  Y
34. SaveToJson					  Y
35.	Use-Openssl					  Y
36.	Set-VMHostProfileExtended	  Y
37. TransferCertToNode			  Y		ExecuteScript, CopyFiletoServer
38. UserPEMFiles				  Y		CreatePEMFiles
39.	VMDirRename					  Y
40. VMCAMint					  N
41. CDDir						  Y
42. CreateVCSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles
43. CreatePscSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles

#>

# Check to see if the url is available.
Param([Parameter(Mandatory=$false)]
		[ValidateSet("excel","json","yaml")]
		[string]$Source = "excel",
    	[Parameter(Mandatory=$false)]
		[switch]$Export,
    	[Parameter(Mandatory=$false)]
    	[string]$FilePath
)

# Clear the screen.
Clear-Host

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook
$ExcelFileName = "vsphere-configs.xlsx"

if (!$FilePath) {$FolderPath = $PWD.path.ToString()}

if ($Source -eq "excel" -and $FilePath) {
    $ExcelFileName  = $FilePath.split("\")[$FilePathn.split("\").count -1]
    $Folderpath     = $FilePath.substring(0,$FilePath.Lastindexof("\"))
}

function Available ($url) {
	$error.clear()
	$output = $null
	
	Write-Host "`r`n Waiting on $url to resolve.`r`n" -foregroundcolor yellow
	$web = New-Object Net.WebClient
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} 
	
	while (!$output) {
		try {$output = $web.DownloadString($url)}
		catch {Start-Sleep -s 30}
	}

	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
	while ((invoke-webrequest -uri $url -UseBasicParsing -TimeoutSec 20).statuscode -ne 200) {
		Write-Host "`r`n $url not ready, sleeping for 60sec.`r`n" -foregroundcolor cyan
		Start-Sleep -s 60
	}
}

# Configure the Autodeploy Service - set certificate, set auto start, register vCenter, and start service.
function ConfigureAutoDeploy ($Deployment, $vihandle, $vcversion) {

	$commandlist = $null
	$commandlist = @()
	
    # Register Autodeploy to vCenter if not changing certificates.
	If (!$Deployment.Certs) {
		$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$commandlist += "export VMWARE_LOG_DIR=/var/log"
		$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
		$commandlist += "export VMWARE_DATA_DIR=/storage"
		$commandlist += "/usr/lib/vmware-vmon/vmon-cli --stop rbd"
		$commandlist += "/usr/bin/autodeploy-register -R -a " + $Deployment.IP + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -p 80"

		ExecuteScript $commandlist $Deployment.hostname "root" $Deployment.VCSARootPass $vihandle}

	# Set Autodeploy (rbd) startype to Automatic and restart service.
	$commandlist = $null
	$commandlist = @()
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"
        
	# imagebuilder set startype to Automatic and restart service.
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"

	# Service update
	ExecuteScript $commandlist $Deployment.hostname "root" $Deployment.VCSARootPass $vihandle
}

function ConfigureAuthProxy ($Deployment, $vihandle, $ADdomain) {

	# Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
	$commandlist = $null
	$commandlist = @()
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
 	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
 	$commandlist += "/usr/lib/vmware-vmcam/bin/camconfig add-domain -d " + $ADDomain.ADDomain + " -u " + $ADDomain.ADvmcamUser + " -w `'" + $ADDomain.ADvmcamPass + "`'"

	# Service update
	ExecuteScript $commandlist $Deployment.hostname "root" $Deployment.VCSARootPass $vihandle
}

function ConfigureAutoDeployRules ($rules, $path, $vihandle) {

	Write-Output $rules | Out-String

	# Turn off signature check - needed to avoid errors from unsigned packages/profiles.
	#$DeployNoSignatureCheck = $true

	ForEach ($rule in $rules) {
		$hpExport = $path + "\" + $rule.ProfileImport
		
		$si = Get-View -Server $vihandle ServiceInstance
		$hpMgr = Get-View -Server $vihandle -Id $si.Content.HostProfileManager
		
		$spec 					  = New-Object VMware.Vim.HostProfileSerializedHostProfileSpec
		$spec.Name 				  = $rule.ProfileName
		$spec.Enabled 			  = $true
		$spec.Annotation		  = $rule.ProfileAnnotation
		$spec.Validating		  = $false
		$spec.profileConfigString = (Get-Content -Path $hpExport)
		
		$hpMgr.CreateProfile($spec)
		
		Write-Output $hpMgr | Out-String

		# Add offline bundles to depot
		$Depotpath = $path + "\" + $rule.SoftwareDepot
		Add-EsxSoftwareDepot $Depotpath

		# Create a new deploy rule.
		$img = Get-EsxImageProfile | Where-Object {$rule.SoftwareDepot.substring(0,$rule.SoftwareDepot.Indexof(".zip"))}
		if ($img.count -gt 1) {$img = $img[1]}
		Write-Output $img | Out-String
		
		$pro = Get-VMHostProfile -Server $vihandle | Where-Object {$_.Name -eq $rule.ProfileName}
		Write-Output $pro | Out-String

		$clu = Get-Datacenter -Server $vihandle -Name $rule.Datacenter | Get-Cluster -Name $rule.Cluster
		Write-Output $clu | Out-String

		Write-Output "New-DeployRule -Name $($rule.RuleName) -Item $img, $pro, $clu -Pattern $($rule.Pattern)" | Out-String
		New-DeployRule -Name $rule.RuleName -Item $img, $pro, $clu -Pattern $rule.Pattern -ErrorAction SilentlyContinue
		
		# Activate the deploy rule.
		Add-DeployRule -DeployRule $rule.RuleName -ErrorAction SilentlyContinue
	}

}

# Configure Private/Public Keys for ssh authentication without password.
function ConfigureCertPairs ($Cert_Dir, $Deployment, $vihandle) {
    $Certpath 	= $Cert_Dir + "\" + $Deployment.Hostname

    # Create key pair for logining in to host without password.
	$commandlist = $null
	$commandlist = @()
	# Create and pemissions .ssh folder.
	$commandlist += "mkdir /root/.ssh"
    $commandlist += "chmod 700 /root/.ssh"
    # Create key pair for logining in to host without password.
    $commandlist += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.Hostname + " -q"
    # Add public key to authorized_keys for root account and permission authorized_keys.
    $commandlist += "cat /root/.ssh/" + $Deployment.Hostname + ".pub >> /root/.ssh/authorized_keys"
	$commandlist += "chmod 600 /root/.ssh/authorized_keys"
    
	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

    # Copy private and public keys to deployment folder for host.
	$filelocations = $null
	$filelocations = @()
	$filelocations += "/root/.ssh/" + $Deployment.Hostname
	$filelocations += $Certpath + "\" + $Deployment.Hostname + ".priv"
	$filelocations += "/root/.ssh/" + $Deployment.Hostname + ".pub"
	$filelocations += $Certpath + "\" + $Deployment.Hostname + ".pub"

    CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle $false
    
	# If there is no global private/public keys pair for the SSO domain hosts, create it.
    If (!(Test-Path $($Cert_Dir + "\" + $Deployment.SSODomainName + ".priv"))) {
        $commandlist = $null
        $commandlist = @()
        # Create key pair for logining in to host without password.
        $commandlist += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.SSODomainName + " -q"
        # Add public key to authorized_keys for root account and permission authorized_keys.
        $commandlist += "cat /root/.ssh/" + $Deployment.SSODomainName + ".pub >> /root/.ssh/authorized_keys"

        ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

        $filelocations = $null
        $filelocations = @()
        $filelocations += "/root/.ssh/" + $Deployment.SSODomainName
        $filelocations += $Cert_Dir + "\" + $Deployment.SSODomainName + ".priv"
        $filelocations += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
        $filelocations += $Cert_Dir + "\" + $Deployment.SSODomainName + ".pub"
    
        CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle $false
    }
    else {
           $filelocations = $null
           $filelocations = @()
           $filelocations += $Cert_Dir + "\" + $Deployment.SSODomainName + ".pub"
           $filelocations += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"

           CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle $true

           $commandlist = $null
           $commandlist = @()
           # Add public cert to authorized keys.
           $commandlist += "cat /root/.ssh/$($Deployment.SSODomainName).pub >> /root/.ssh/authorized_keys"
   
           ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
    }

}

# Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.
function ConfigureIdentity67 ($Deployment) {

	# Add AD domain as Native Identity Source.
	Write-Output "============ Adding AD Domain as Identity Source for SSO on vCenter Instance 6.7 ============" | Out-String

	Available $("https://" + $Deployment.Hostname + "/ui/")
	
	Start-Sleep -Seconds 10

	# Get list of existing Internet Explorer instances.
	$instances = Get-Process -Name iexplore -erroraction silentlycontinue
			
	$ie = New-Object -com InternetExplorer.Application

	$ie.visible=$false

	$uri = "https://" + $Deployment.Hostname + "/ui/"
		
	Do {
		$ie.navigate($uri)

		while($ie.ReadyState -ne 4) {start-sleep -m 100}

		while($ie.document.ReadyState -ne "complete") {start-sleep -m 100}

		Write-Output $ie.document.url | Out-String

		Start-Sleep -Seconds 30

	} Until ($ie.document.url -match "websso")
		
	Write-Output "ie" | Out-String
	Write-Output $ie | Out-String

	Separatorline
		
	start-sleep 1

	$ie.document.documentElement.GetElementsByClassName("margeTextInput")[0].value = 'administrator@' + $Deployment.SSODomainName
	$ie.document.documentElement.GetElementsByClassName("margeTextInput")[1].value = $Deployment.SSOAdminPass
		
	start-sleep 1
		
	# Enable the submit button and click it.
	$ie.document.documentElement.GetElementsByClassName("button blue")[0].Disabled = $false
	$ie.document.documentElement.GetElementsByClassName("button blue")[0].click()

	start-sleep 10
		
	$uri = "https://" + $Deployment.Hostname + "/ui/#?extensionId=vsphere.core.administration.configurationView"

	$ie.navigate($uri)
		
	start-sleep 1
		
	($ie.document.documentElement.getElementsByClassName('btn btn-link nav-link nav-item') | Where-Object {$_.id -eq 'clr-tab-link-3'}).click()
		
	start-sleep 1
			
	($ie.document.documentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'addNewIdentity'}).click()
		
	start-sleep 1
		
	$ie.document.documentElement.getElementsByClassName('btn btn-primary')[0].click()
		
	start-sleep 1
		
	$selections = ($ie.document.documentElement.getElementsByTagName("clr-dg-cell") | Select-Object outertext).outertext -replace " ",""
	$row =  0..2 | Where-Object {$selections[1,7,13][$_] -eq $ADInfo.ADDomain}

	$ie.document.documentElement.getElementsByClassName("radio")[$row].childnodes[3].click()
		
	($ie.document.documentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'defaultIdentity'}).click()
		
	start-sleep 1
		
	$ie.document.documentElement.getElementsByClassName('btn btn-primary')[0].click()
	
	# Exit Internet Explorer.
	$ie.quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ie)

	$ie = $null

	# Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
	$newinstances = Get-Process -Name iexplore
	$newinstances | Where-Object {$instances.id -notcontains $_.id} | stop-process
	
	Write-Output "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String
}


# Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.
function ConfigureIdentity65 ($Deployment) {

	# Add AD domain as Native Identity Source.
	Write-Output "============ Adding AD Domain as Identity Source for SSO on PSC Instance 6.5 ============" | Out-String
			
	Start-Sleep -Seconds 10

    # Get list of existing Internet Explorer instances.
	$instances = Get-Process -Name iexplore -erroraction silentlycontinue
					
	# Create new Internet Explorer instance.
	$ie = New-Object -com InternetExplorer.Application

	# Don't make the Internet Explorer instance visible.
	$ie.visible=$false

	# Navigate to https://<fqdn of host>/psc/
	$ie.navigate($("https://" + $Deployment.Hostname + "/psc/"))

	# Wait while page finishes loading.
	while($ie.ReadyState -ne 4) {start-sleep -m 100}
	while($ie.document.ReadyState -ne "complete") {start-sleep -m 100}
			
	Separatorline

	Write-Output "ie" | Out-String
	Write-Output $ie | Out-String

	Separatorline
			
    # Fill in the username and password fields with the SSO Administrator credentials.
	$ie.document.documentElement.getElementsByClassName('margeTextInput')[0].value = 'administrator@' + $Deployment.SSODomainName
	$ie.document.documentElement.getElementsByClassName('margeTextInput')[1].value = $Deployment.SSOAdminPass
				
    # Enable the submit button and click it.
	$ie.document.documentElement.getElementsByClassName('button blue')[0].Disabled = $false
	$ie.document.documentElement.getElementsByClassName('button blue')[0].click()

	start-sleep 10
				
    # Navigate to the add Identity Sources page for the SSO.
	$ie.navigate("https://" + $Deployment.Hostname + "/psc/#?extensionId=sso.identity.sources.extension") 

	Write-Output $ie | Out-String

	start-sleep 1

	# Select the Add Identity Source button and click it.
	$ca = $ie.document.documentElement.getElementsByClassName('vui-action-label ng-binding ng-scope') | Select-Object -first 1
	$ca.click()
				
	start-sleep 1

    # Click the Active Directory Type Radio button.
	$ie.document.documentElement.getElementsByClassName('ng-pristine ng-untouched ng-valid')[0].click()

	start-sleep 1
			
    # Click OK.
	$ca = $ie.document.documentElement.getElementsByClassName('ng-binding') | Where-Object {$_.innerHTML -eq "OK"}
	$ca.click()
			
    # Exit Internet Explorer.
	$ie.quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ie)

	$ca = $null
	$ie = $null
			
	# Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
	$newinstances = Get-Process -Name iexplore -ErrorAction SilentlyContinue
	$newinstances | Where-Object {$instances.id -notcontains $_.id} | stop-process

	Write-Output "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String
			
}

function ConfigureSSOGroups ($Deployment, $ADInfo, $vihandle) {

	Write-Output "============ Add AD Groups to SSO Admin Groups ============" | Out-String

	$sub_domain		= $Deployment.SSODomainName.split(".")[0]
	$domain_ext		= $Deployment.SSODomainName.split(".")[1]

	# Active Directory variables
	$AD_admins_group_sid	= (Get-ADgroup -Identity $ADInfo.ADvCenterAdmins).sid.value

	$versionregex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $script | Out-String

	$viversion = $(ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput.Split("") | select-string -pattern $versionregex
		
	Write-Output $viversion

	if ($Deployment.Parent -eq "null") {$ldapserver = $Deployment.Hostname}
		else {$ldapserver = $Deployment.Parent}

	$commandlist = $null
	$commandlist = @()
	
	# Set Default SSO Identity Source Domain
	If ($viversion -match "6.5.") {	
		$commandlist += "echo -e `"dn: cn=$($Deployment.SSODomainName),cn=Tenants,cn=IdentityManager,cn=Services,dc=$sub_domain,dc=$domain_ext`" >> defaultdomain.ldif"
		$commandlist += "echo -e `"changetype: modify`" >> defaultdomain.ldif"
		$commandlist += "echo -e `"replace: vmwSTSDefaultIdentityProvider`" >> defaultdomain.ldif"
		$commandlist += "echo -e `"vmwSTSDefaultIdentityProvider: $($ADInfo.ADDomain)`" >> defaultdomain.ldif"
		$commandlist += "echo -e `"-`" >> defaultdomain.ldif"
		$commandlist += "/opt/likewise/bin/ldapmodify -f /root/defaultdomain.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$($Deployment.VCSARootPass)`'"
	}

	# Add AD vCenter Admins to Component Administrators SSO Group.
	$commandlist += "echo -e `"dn: cn=ComponentManager.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_cma.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_cma.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_cma.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_cma.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_cma.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_cma.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Add AD vCenter Admins to License Administrators SSO Group.
	$commandlist += "echo -e `"dn: cn=LicenseService.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_la.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_la.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_la.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_la.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_la.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_la.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Add AD vCenter Admins to Administrators SSO Group.
	$commandlist += "echo -e `"dn: cn=Administrators,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_adm.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_adm.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_adm.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_adm.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_adm.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_adm.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Add AD vCenter Admins to Certificate Authority Administrators SSO Group.
	$commandlist += "echo -e `"dn: cn=CAAdmins,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_caa.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_caa.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_caa.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_caa.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_caa.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_caa.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Add AD vCenter Admins to Users SSO Group.
	$commandlist += "echo -e `"dn: cn=Users,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_usr.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_usr.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_usr.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_usr.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_usr.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_usr.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Add AD vCenter Admins to System Configuration Administrators SSO Group.
	$commandlist += "echo -e `"dn: cn=SystemConfiguration.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_sca.ldif"
	$commandlist += "echo -e `"changetype: modify`" >> groupadd_sca.ldif"
	$commandlist += "echo -e `"add: member`" >> groupadd_sca.ldif"
	$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_sca.ldif"
	$commandlist += "echo -e `"-`" >> groupadd_sca.ldif"
	$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_sca.ldif -h $ldapserver -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'" + $Deployment.VCSARootPass + "`'"
			
	# Excute the commands in $commandlist on the vcsa.
	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
}

function ConfigureLicensing ($Licenses, $vihandle) {
# http://vniklas.djungeln.se/2012/03/29/a-powercli-function-to-manage-vmware-vsphere-licenses/
	Write-Output $Licenses | Out-String
	ForEach ($License in $Licenses) {
		$LicMgr		= $null
		$AddLic		= $null
		$LicType	= $null
		# Add License Key
		$LicMgr  = Get-View -Server $vihandle ServiceInstance
		$AddLic  = Get-View -Server $vihandle $LicMgr.Content.LicenseManager
		Write-Output "Current Licenses in vCenter $($Addlic.Licenses.LicenseKey)" | Out-String
		If (!($Addlic.Licenses.LicenseKey | Where-Object {$_ -eq $license.LicKey.trim()})) {
			Write-Output "Adding $($License.LicKey) to vCenter" | Out-String
			$LicType = $AddLic.AddLicense($($License.LicKey.trim()),$null)
		}
		
		If ($LicType.Name -like "*vcenter*") {
			# Assign vCenter License
			$vcUuid 		= $LicMgr.Content.About.InstanceUuid
			$vcDisplayName	= $LicMgr.Content.About.Name
			$licAssignMgr	= Get-View -Server $vihandle $AddLic.licenseAssignmentManager
			If ($licAssignMgr) { 
				$licAssignMgr.UpdateAssignedLicense($vcUuid, $License.LicKey, $vcDisplayName)
			}
		}
		Else {
			  # Assign Esxi License
			  $licDataMgr = Get-LicenseDataManager -Server $vihandle
			  For ($i=0;$i -lt $License.ApplyType.Split(",").count;$i++) {
				   Switch ($License.ApplyType.Split(",")[$i]) {
					 CL {$viContainer = Get-Cluster -Server $vihandle -Name $License.ApplyTo.Split(",")[$i]; Break}
					 DC {If($License.ApplyTo.Split(",")[$i] -eq "Datacenters") {
						 	$viContainer = Get-Folder -Server $vihandle -Name $License.ApplyTo.Split(",")[$i] -Type "Datacenter"
					 	 } Else {$viContainer = Get-Datacenter -Server $vihandle -Name $License.ApplyTo.Split(",")[$i]}; Break}
					 FO {$viContainer = Get-Folder -Server $vihandle -Name $License.ApplyTo.Split(",")[$i] -Type "HostAndCluster"; Break}
					 default {$viContainer = $null; Break}
				   }

				   Write-Output $viContainer | Out-String

				   If ($viContainer) {
				   	   $LicData					= New-Object VMware.VimAutomation.License.Types.LicenseData
				   	   $LicKeyEntry				= New-Object Vmware.VimAutomation.License.Types.LicenseKeyEntry
				       $LicKeyEntry.TypeId 		= "vmware-vsphere"
				       $LicKeyEntry.LicenseKey	= $License.LicKey
				       $LicData.LicenseKeys 	+= $LicKeyEntry
				       $LicDataMgr.UpdateAssociatedLicenseData($viContainer.Uid, $LicData)
				       $LicDataMgr.QueryAssociatedLicenseData($viContainer.Uid)
				   }
			  }
		}
	}
}

# Configure Network Dumpster to Auto Start and start service.
function ConfigureNetdumpster ($hostname, $username, $password, $vihandle, $vcversion) {
	$commandlist = $null
	$commandlist = @()

	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --update netdumper --starttype AUTOMATIC"
	$commandlist += "/usr/lib/vmware-vmon/vmon-cli --start netdumper"

	# Service update
	ExecuteScript $commandlist $hostname $username $password $vihandle
}

# Configure TFTP, set firewall exemption, set service to auto start, start service.
function ConfigureTFTP ($hostname, $username, $password, $vihandle) {
	$commandlist = $null
	$commandlist = @()

	# Set Permanent Firewall Exception
	$commandlist += 'echo -e "{" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "  	\"firewall\": {" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "    	\"enable\": true," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "    	\"rules\": [" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "      	{" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"protocol\": \"tcp\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "      	}," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "      {" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"protocol\": \"udp\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "        	\"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "      }" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "    ]" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "  }" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += 'echo -e "}" >> /etc/vmware/appliance/firewall/tftp'
	$commandlist += "echo `"#!/bin/bash`" > /tmp/tftpcmd"
	$commandlist += "echo -n `"sed -i `" >> /tmp/tftpcmd"
	$commandlist += "echo -n `'`"s/`' >> /tmp/tftpcmd"
	$commandlist += "echo -n \`'/ >> /tmp/tftpcmd"
	$commandlist += "echo -n `'\`' >> /tmp/tftpcmd"
	$commandlist += "echo -n `'`"/g`' >> /tmp/tftpcmd"
	$commandlist += "echo -n `'`"`' >> /tmp/tftpcmd"
	$commandlist += "echo -n `" /etc/vmware/appliance/firewall/tftp`" >> /tmp/tftpcmd"
	$commandlist += "chmod a+x /tmp/tftpcmd"
	$commandlist += "/tmp/tftpcmd"
	$commandlist += "rm /tmp/tftpcmd"

	$commandlist += "more /etc/vmware/appliance/firewall/tftp"
	# Enable TFTP service.
	$commandlist += "/sbin/chkconfig atftpd on"
	# Start TFTP service.
	$commandlist += "/etc/init.d/atftpd start"
	$commandlist += "/usr/lib/applmgmt/networking/bin/firewall-reload"
	# Set Firewall Exception until reboot.
	$commandlist += "iptables -A port_filter -p udp -m udp --dport 69 -j ACCEPT"
	
	# Service update
	ExecuteScript $commandlist $hostname $username $password $vihandle
}

function ConvertPSObjectToExcel {
    Param (
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
	$values  = $InputObject | ForEach-Object {$_.psobject.properties.Value}
	
	If ($headers.count -gt 1) {
		$values[($values.length - 1)..0] | ForEach-Object {$mystack.Push($_)}
		$headers[($headers.length - 1)..0] | ForEach-Object {$mystack.Push($_)}
	}
	Else {
		$values	 | ForEach-Object {$mystack.Push($_)}
		$headers | ForEach-Object {$mystack.Push($_)}
	}			
	
	$columns = $headers.count
	$rows = $values.count/$headers.count + 1
	$array = New-Object 'object[,]' $rows, $columns
		
	For ($i=0;$i -lt $rows;$i++)
		{ 
			For ($j = 0; $j -lt $columns; $j++) {
				$array[$i,$j] = $mystack.Pop()
			}
		}

	$WorkSheet.name = $SheetName
	If ($columns -le 26) {
		$ascii = [char]($columns + 96) + $rows
	} 
	Else { $ascii = "aa" + $rows}
	$range = $WorkSheet.Range("a1",$ascii)
	$range.Value2 = $array
}

# Convert PS Object to Hashtable.
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

# Deploy a VCSA.
function Deploy ($ParameterList, $OvfToolPath, $LogPath) {
	$pscs			= @("tiny","small","medium","large","infrastructure")

	$ArgumentList	= @()
	$OvfTool		= $OvfToolPath + "\ovftool.exe"

	# Get Esxi Host Certificate Thumbrpint.
	$url = "https://" + $ParameterList.esxiHost
	$webRequest = [Net.WebRequest]::Create($url)
	Try { $webRequest.GetResponse() } Catch {}
	$esxiCert = $webRequest.ServicePoint.Certificate
	$esxiThumbPrint = $esxiCert.GetCertHashString() -replace '(..(?!$))','$1:'
	
	If ($parameterlist.Action -ne "--version") {
		$ArgumentList += "--X:logFile=$LogPath\ofvtool_" + $ParameterList.vmName + "-$(get-date -format mm-dd-yyyy_HH-mm).log"
		$ArgumentList += "--X:logLevel=verbose"
		$ArgumentList += "--acceptAllEulas"
		$ArgumentList += "--skipManifestCheck"
		$ArgumentList += "--targetSSLThumbprint=$esxiThumbPrint"
		$ArgumentList += "--X:injectOvfEnv"
		$ArgumentList += "--allowExtraConfig"
		$ArgumentList += "--X:enableHiddenProperties"
		$ArgumentList += "--X:waitForIp"
		$ArgumentList += "--sourceType=OVA"
		$ArgumentList += "--powerOn"
		$ArgumentList += "--net:Network 1=" + $ParameterList.EsxiNet
		$ArgumentList += "--datastore=" + $ParameterList.esxiDatastore
		$ArgumentList += "--diskMode=" + $ParameterList.DiskMode
		$ArgumentList += "--name=" + $ParameterList.vmName
		$ArgumentList += "--deploymentOption=" + $ParameterList.DeployType
		If ($parameterlist.DeployType -like "*management*") {
			$ArgumentList += "--prop:guestinfo.cis.system.vm0.hostname=" + $ParameterList.Parent
		}
		$ArgumentList += "--prop:guestinfo.cis.vmdir.domain-name=" + $ParameterList.SSODomainName
		$ArgumentList += "--prop:guestinfo.cis.vmdir.site-name=" + $ParameterList.SSOSiteName
		$ArgumentList += "--prop:guestinfo.cis.vmdir.password=" + $ParameterList.SSOAdminPass
		If ($parameterlist.Action -eq "first" -and $pscs -contains $ParameterList.DeployType) {
			$ArgumentList += "--prop:guestinfo.cis.vmdir.first-instance=True"
		}
		Else {
			  $ArgumentList += "--prop:guestinfo.cis.vmdir.first-instance=False"
			  $ArgumentList += "--prop:guestinfo.cis.vmdir.replication-partner-hostname=" + $ParameterList.Parent
		}
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.addr.family=" + $ParameterList.NetFamily
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.addr=" + $ParameterList.IP
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.pnid=" + $ParameterList.Hostname
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.prefix=" + $ParameterList.NetPrefix
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.mode=" + $ParameterList.NetMode
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.dns.servers=" + $ParameterList.DNS
		$ArgumentList += "--prop:guestinfo.cis.appliance.net.gateway=" + $ParameterList.Gateway
		$ArgumentList += "--prop:guestinfo.cis.appliance.root.passwd=" + $ParameterList.VCSARootPass
		$ArgumentList += "--prop:guestinfo.cis.appliance.ssh.enabled=" + $ParameterList.EnableSSH
		$ArgumentList += "--prop:guestinfo.cis.appliance.ntp.servers=" + $ParameterList.NTP
		$ArgumentList += "--prop:guestinfo.cis.deployment.autoconfig=True"
		$ArgumentList += "--prop:guestinfo.cis.clientlocale=en"
		$ArgumentList += "--prop:guestinfo.cis.ceip_enabled=False"
		$ArgumentList += $ParameterList.OVA
		$ArgumentList += "vi://" + $ParameterList.esxiRootUser + "`:" + $ParameterList.esxiRootPass + "@" + $ParameterList.esxiHost
	}
	
	Write-Output $ArgumentList | Out-String
	
	& $OvfTool $ArgumentList

	Return
}

# Create Folders
function CreateFolders ($folders, $vihandle) {

	Separatorline
	
	ForEach ($folder in $folders) {
		Write-Output $folder.Name | Out-String
		ForEach ($datacenter in get-datacenter -Server $vihandle) {
			If ($folder.datacenter.split(",") -match "all|$($Datacenter.name)") {	
				$location = $datacenter | get-folder -name $folder.Location | Where-Object {$_.Parentid -notlike "*ha*"}
				Write-Output $location | Out-String
				New-Folder -Server $vihandle -Name $folder.Name -Location $location -Confirm:$false
			}
		}	
	}
	   
	Separatorline
}

# Create Roles
function CreateRoles ($Roles, $vihandle) {
	Separatorline

	$ExistingRoles = Get-ViRole -Server $vihandle | Select-Object Name

	$Names = $($Roles | Select-Object Name -Unique) | Where-Object {$ExistingRoles.name -notcontains $_.name}

	Write-Output $Names | Out-String

	ForEach ($Name in $Names) {
		$vPrivilege = $Roles | Where-Object {$_.Name -like $Name.Name} | Select-Object Privilege
		
		Write-Output $vPrivilege | Out-String
		
		New-VIRole -Server $vihandle -Name $Name.Name -Privilege (Get-VIPrivilege -Server $vihandle | Where-Object {$vPrivilege.Privilege -like $_.id})
	}

	Separatorline
}

# Set Permissions
function CreatePermissions ($vPermissions, $vihandle) {

	Separatorline

	Write-Output  "Permissions:" $vPermissions  | Out-String
	
	ForEach ($Permission in $vPermissions) {
		$Entity = Get-Inventory -Name $Permission.Entity | Where-Object {$_.Id -match $Permission.Location}
		If ($Permission.Group) {
			$Principal = Get-VIAccount -Group -Name $Permission.Principal -Server $vihandle
		}
		Else { 
			$Principal = Get-VIAccount -Name $Permission.Principal -Server $vihandle
		}

		Write-Output "New-VIPermission -Server $vihandle -Entity $Entity -Principal $Principal -Role $($Permission.Role) -Propagate $([System.Convert]::ToBoolean($Permission.Propagate))" | Out-String

		New-VIPermission -Server $vihandle -Entity $Entity -Principal $Principal -Role $Permission.Role -Propagate $([System.Convert]::ToBoolean($Permission.Propagate))
		
	}
	
	Separatorline
}

# Execute a script via Invoke-VMScript.
function ExecuteScript ($script, $hostname, $username, $password, $vihandle) {

	Separatorline
	
	$script | ForEach-Object {Write-Output $_} | Out-String
	
	Separatorline
	
	$output = Invoke-VMScript -ScriptText $(If ($script.count -gt 1) {$script -join(";")} Else {$script}) -vm $hostname -GuestUser $username -GuestPassword $password -Server $vihandle

	Return $output
}

# Copy a file to a VM.
function CopyFiletoServer ($locations, $hostname, $username, $password, $vihandle, $upload) {
	
	Separatorline
	
	For ($i=0; $i -le ($locations.count/2)-1;$i++) {
		Write-Host "Sources: `n"
		Write-Output $locations[$i*2] | Out-String
		Write-Host "Destinations: `n"
		Write-Output $locations[($i*2)+1] | Out-String
		If ($upload) {
			Copy-VMGuestFile -VM $hostname -LocalToGuest -Source $($locations[$i*2]) -Destination $($locations[($i*2)+1]) -guestuser $username -GuestPassword $password -Server $vihandle -force}
		Else {
			Copy-VMGuestFile -VM $hostname -GuestToLocal -Source $($locations[$i*2]) -Destination $($locations[($i*2)+1]) -guestuser $username -GuestPassword $password -Server $vihandle -force
		}
	}

	Separatorline
}

# Download the Node self signed certificate and install it in the local trusted root certificate store.
function InstallNodeRootCert ($Certpath, $Deployment, $vihandle) {

	SeparatorLine

	$RootCertPath = $Certpath + "\" + $Deployment.Hostname.Split(".")[0] + "_self_signed_root_cert.crt"

	$commandlist 	= $null
	$commandlist 	= @()
	$commandlist 	+= "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`' | grep `'CN(id):`'"

	$certid = $(ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput.split("")[2]

	$commandlist 	= $null
	$commandlist 	= @()
	$commandlist    += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert get --id $certid --outcert /root/vcrootcert.crt --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
	
	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

	$filelocations = $null
	$filelocations = @()
	$filelocations += "/root/vcrootcert.crt"
	$filelocations += $RootCertPath

	CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle $false

	Import-Certificate -FilePath $RootCertPath -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

	SeparatorLine
}


# Join the VCSA to the Windows AD Domain.
function JoinADDomain ($Deployment, $ADInfo, $vihandle) {
			$pscdeployments	= @("tiny","small","medium","large","infrastructure")

			Write-Output "== Joining $($Deployment.vmName) to the windows domain ==" | Out-String

			Separatorline
		
			$commandlist = $null
			$commandlist = @()
			$commandlist += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
			$commandlist += 'export VMWARE_LOG_DIR=/var/log'
			$commandlist += 'export VMWARE_DATA_DIR=/storage'
			$commandlist += 'export VMWARE_CFG_DIR=/etc/vmware'
			$commandlist += '/usr/bin/service-control --start --all --ignore'
			$commandlist += "/opt/likewise/bin/domainjoin-cli join " + $ADInfo.ADDomain + " " + $ADInfo.ADJoinUser + " `'" + $ADInfo.ADJoinPass + "`'"
			$commandlist += "/opt/likewise/bin/domainjoin-cli query"
	
			# Excute the commands in $commandlist on the vcsa.
			ExecuteScript $commandlist $Deployment.vmName "root" $Deployment.VCSARootPass $vihandle

			Restart-VMGuest -VM $Deployment.vmName -Server $vihandle -Confirm:$false

			# Write separator line to transcript.
			Separatorline
			
			# Wait 60 seconds before checking availability to make sure the vcsa is booting up and not in the process of shutting down.
			Start-Sleep -s 60
			
			# Wait until the vcsa is available.
			Available $("https://" + $Deployment.Hostname)
			
			# Write separator line to transcript.
			Separatorline

			# Check domain status.
			$commandlist = $null
			$commandlist = @()
			$commandlist += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
			$commandlist += 'export VMWARE_LOG_DIR=/var/log'
			$commandlist += 'export VMWARE_DATA_DIR=/storage'
			$commandlist += 'export VMWARE_CFG_DIR=/etc/vmware'
			$commandlist += '/usr/bin/service-control --start --all --ignore'
			$commandlist += "/opt/likewise/bin/domainjoin-cli query"
	
			# Excute the commands in $commandlist on the vcsa.
			ExecuteScript $commandlist $Deployment.vmName "root" $Deployment.VCSARootPass $vihandle

			# if the vcsa is the first PSC in the vsphere domain, set the default identity source to the windows domain,
			# add the windows AD group to the admin groups of the PSC.
			$commandlist = $null
			$commandlist = "/opt/likewise/bin/ldapsearch -h " + $Deployment.Hostname + " -w `'" + $Deployment.VCSARootPass + "`' -x -D `"cn=Administrator,cn=Users,dc=lab-hcmny,dc=com`" -b `"cn=lab-hcmny.com,cn=Tenants,cn=IdentityManager,cn=services,dc=lab-hcmny,dc=com`" | grep vmwSTSDefaultIdentityProvider"

			$DefaultIdentitySource = $(ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput

			$versionregex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
			$script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"
		
			Write-Output $script | Out-String

			$viversion = $(ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput.Split("") | select-string -pattern $versionregex
		
			Write-Output $viversion

			If ($viversion -match "6.7." -and $Deployment.DeployType -ne "infrastructure" -and $DefaultIdentitySource -ne $ADInfo.ADDomain) {	
				# Write separator line to transcript.
				Separatorline

				ConfigureIdentity67 $Deployment

				Separatorline

				ConfigureSSOGroups $Deployment $ADInfo $vihandle
			}
			ElseIf ($viversion -match "6.5." -and $pscdeployments -contains $Deployment.DeployType) {
				Separatorline

				ConfigureIdentity65 $Deployment

				Separatorline

				ConfigureSSOGroups $Deployment $ADInfo $vihandle
			}

		Separatorline
}

# Convert OS Customization Object to Stirng needed to run the command.
function OSString
{
    Param (
        [Parameter(ValueFromPipeline)]
        $InputObject
	)
	
	$o = "New-OSCustomizationSpec "
	ForEach ($i in $InputObject.PSObject.Properties) {
		If ($i.Value -ne $null) {
			$o = $o.insert($o.length,"-" + $i.Name + ' "' + $i.Value + '" ')}
	}

	$o = $o -replace " `"true`"", ""
	$o = $o -replace " -ChangeSid `"false`"",""
	$o = $o -replace " -DeleteAccounts `"false`"",""

	Write-Output $o | out-string

	Invoke-Expression $o
}

# Replace $null values with "<null>" string in objects.
function RemoveNull
{
    Param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	$InputObject | ForEach-Object {$_.psobject.properties | Where-Object {!$_.value -and $_.TypeNameOfValue -ne "System.Boolean"} | ForEach-Object {$_.value = "<null>"}}
}

# Replace "<null>" string values with $null in objects.
function ReplaceNull
{
    Param (
        [Parameter(ValueFromPipeline)]
        $InputObject
	)
	
	For ($i=0;$i -lt ($InputObject | Measure-Object).count;$i++)
		{$InputObject[$i].psobject.properties | Where-Object {If($_.Value -match "<null>") {$_.Value = $null}}}
}

# Print a dated line to standard output.
function Separatorline {
	$Date = Get-Date
	Write-Output "`n---------------------------- $Date ----------------------------`r`n" | Out-String
}

#
# Certificate functions
#

function ChainCAs ($Cert_Dir, $rootcer, $intermcer, $interm2cer) {
# Chains CA files together in a PEM encoded file. Supports root CA and two subordinates.
# Skip if we have pending cert requests
	If ($Script:CertsWaitingForApproval) {Return}
	# Prompt for Root cert if it's not there yet
	If (Test-Path $intermcer) {
		get-content -path $intermcer,$rootcer | set-content -path $Cert_Dir\chain.cer
	}
	If (Test-Path $interm2cer) {
		get-content -path $interm2cer,$intermcer,$rootcer | set-content -path $Cert_Dir\chain.cer
	}
}

function CheckOpenSSL ($openssl) {
   If (!(Test-Path $openssl)) {Throw "Openssl required, unable to download, please install manually. Use latest OpenSSL 1.0.2."; Exit}
}

function CreatePEMFiles ($SVCDir, $CertFile, $CerFile, $Cert_Dir, $InstanceCertDir) {
	# Create PEM file for supplied certificate
	# Skip if we have pending cert requests
	If ($Script:CertsWaitingForApproval) {Return;}
	If (Test-Path $Cert_Dir\chain.cer) {$chaincer = "$Cert_Dir\chain.cer"}
	Else {$chaincer = "$Cert_Dir\root64.cer"}
	
	If (!(Test-Path $InstanceCertDir\$SVCDir\$CertFile)) {
		Write-Host "$InstanceCertDir\$SVCDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
	}
	Else {$RUI = get-content $InstanceCertDir\$SVCDir\$CertFile
		  $ChainCont = get-content $chaincer -encoding default
		  $RUI + $ChainCont | out-file  $InstanceCertDir\$SVCDir\$CerFile -Encoding default
		  Write-Host "PEM file $InstanceCertDir\$SVCDir\$CerFile succesfully created" -ForegroundColor Yellow
	}
	Set-Location $Cert_Dir	
}

#
# CSR Functions
#

function CreateCSR ($SVCDir, $CSRName, $CFGName, $PrivFile, $Flag, $Cert_Dir, $Certinfo) {
# Create RSA private key and CSR for vSphere 6.0 SSL templates
	If (!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	# vSphere 5 and 6 CSR Options are different. Set according to flag type
	# VUM 6.0 needs vSphere 5 template type
	If ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	If ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo.CompanyName
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo.CompanyName
	$MachineShort = $DEFFQDN.split(".")[0] 
	$MachineIP = [System.Net.Dns]::GetHostAddresses("$DEFFQDN").IPAddressToString
	$RequestTemplate = "[ req ]
	default_md = sha512
	default_bits = 2048
	default_keyfile = rui.key
	distinguished_name = req_distinguished_name
	encrypt_key = no
	prompt = no
	string_mask = nombstr
	req_extensions = v3_req
	
	[ v3_req ]
	basicConstraints = CA:FALSE
	keyUsage = digitalSignature, keyEncipherment, $CSROption1
	subjectAltName = IP:$MachineIP,DNS:$DEFFQDN,DNS:$MachineShort
	
	[ req_distinguished_name ]
	countryName = $($Certinfo.Country)
	stateOrProvinceName = $($Certinfo.State)
	localityName = $($Certinfo.Locality)
	0.organizationName = $($Certinfo.OrgName)
	organizationalUnitName = $($Certinfo.OrgUnit)
	commonName = $CommonName
	"
	Set-Location $Cert_Dir
    If (!(Test-Path $SVCDir)) {new-Item Machine -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$Cert_Dir\$SVCDir\$CFGName" -Encoding Default -Force 
    Use-OpenSSL "req -new -nodes -out `"$Cert_Dir\$SVCDir\$CSRName`" -keyout `"$Cert_Dir\$SVCDir\$CSRName.key`" -config `"$Cert_Dir\$SVCDir\$CFGName`""
    Use-OpenSSL "rsa -in `"$Cert_Dir\$SVCDir\$CSRName.key`" -out `"$Cert_Dir\$SVCDir\$PrivFile`""
    Remove-Item $SVCDir\$CSRName.key
    Write-Host "CSR is located at $Cert_Dir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateSolutionCSR ($SVCDir, $CSRName, $CFGName, $PrivFile, $Flag, $SolutionUser, $Cert_Dir, $Certinfo) {
# Create RSA private key and CSR for vSphere 6.0 SSL templates
	If (!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	# vSphere 5 and 6 CSR Options are different. Set according to flag type
	# VUM 6.0 needs vSphere 5 template type
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo.CompanyName
	If ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	If ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo.CompanyName
	$MachineShort = $DEFFQDN.split(".")[0] 
	$MachineIP = [System.Net.Dns]::GetHostAddresses("$DEFFQDN").IPAddressToString
	$RequestTemplate = "[ req ]
	default_md = sha512
	default_bits = 2048
	default_keyfile = rui.key
	distinguished_name = req_distinguished_name
	encrypt_key = no
	prompt = no
	string_mask = nombstr
	req_extensions = v3_req

	[ v3_req ]
	basicConstraints = CA:FALSE
	keyUsage = digitalSignature, keyEncipherment, $CSROption1
	subjectAltName = IP:$MachineIP,DNS:$DEFFQDN,DNS:$MachineShort

	[ req_distinguished_name ]
	countryName = $($Certinfo.Country)
	stateOrProvinceName = $($Certinfo.State)
	localityName = $($Certinfo.Locality)
	0.organizationName = $($Certinfo.OrgName)
	organizationalUnitName = $($Certinfo.OrgUnit)
	commonName = $CommonName
	"
	Set-Location $Cert_Dir
	If (!(Test-Path $SVCDir)) { new-Item Machine -Type Directory }
	# Create CSR and private key
	$Out = $RequestTemplate | Out-File "$Cert_Dir\$SVCDir\$CFGName" -Encoding Default -Force 
	Use-OpenSSL "req -new -nodes -out `"$Cert_Dir\$SVCDir\$CSRName`" -keyout `"$Cert_Dir\$SVCDir\$CSRName.key`" -config `"$Cert_Dir\$SVCDir\$CFGName`""
	Use-OpenSSL "rsa -in `"$Cert_Dir\$SVCDir\$CSRName.key`" -out `"$Cert_Dir\$SVCDir\$PrivFile`""
	Remove-Item $SVCDir\$CSRName.key
    Write-Host "CSR is located at $Cert_Dir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateVMCACSR {
# Create RSA private key and CSR
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$VPSCFQDN = $(
		Write-Host "Is the vCenter Platform Services Controller FQDN $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new PSC FQDN"
		If ($inputFQDN) {$inputFQDN} Else {$DEFFQDN}
	)
	$RequestTemplate = "[ req ]
	default_md = sha512
	default_bits = 2048
	default_keyfile = rui.key
	distinguished_name = req_distinguished_name
	encrypt_key = no
	prompt = no
	string_mask = nombstr
	req_extensions = v3_req
	
	[ v3_req ]
	basicConstraints = CA:TRUE
	
	[ req_distinguished_name ]
	countryName = $Country
	stateOrProvinceName = $State
	localityName = $Locality
	0.organizationName = $OrgUnit
	commonName = $VPSCFQDN
	"
	Set-Location $Cert_Dir
    If (!(Test-Path VMCA)) {new-Item VMCA -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$Cert_Dir\VMCA\root_signing_cert.cfg" -Encoding Default -Force
    Use-OpenSSL "req -new -nodes -out `"$Cert_Dir\VMCA\root_signing_cert.csr`" -keyout `"$Cert_Dir\VMCA\vmca-org.key`" -config `"$Cert_Dir\VMCA\root_signing_cert.cfg`""
    Use-OpenSSL "rsa -in `"$Cert_Dir\VMCA\vmca-org.key`" -out `"$Cert_Dir\VMCA\root_signing_cert.key`""
    Remove-Item VMCA\vmca-org.key
    Write-Host "CSR is located at $Cert_Dir\VMCA\root_signing_cert.csr" -ForegroundColor Yellow
}

function DisplayVMDir {
	# Displays the currently used VMDir certificate via OpenSSL
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$VMDirHost = $(
		Write-Host "Do you want to dispaly the VMDir SSL certificate of $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		If ($InputFQDN) {$InputFQDN} Else {$DEFFQDN})
	Use-OpenSSL "s_client -servername $VMDirHost -connect `"${VMDirHost}:636`""
}

function DownloadRoots ($Cert_Dir, $RootCA, $rootcer, $SubCA, $intermcer, $SubCA2, $interm2cer, $CADownload) {
# https://powershell.org/forums/topic/export-certificate-using-base-64-cer-format-with-powershell/
# Download Root CA public certificate, if defined
# if the certificate exists (root64.cer) then it won't attempt to download
	If ($RootCA) {
		If (!(Test-Path -Path $rootcer)) {
			$CertThumbprint = (Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -match $rootca.split(".")[0] -and $_.SignatureAlgorithm.FriendlyName -match 1} | Sort-Object NotAfter -Descending | Select-Object -first 1).Thumbprint

			$cert = Get-Item -Path cert:\LocalMachine\root\$CertThumbprint
			$certFile = "$Cert_Dir\root64.cer"
			$content = @(    
				'-----BEGIN CERTIFICATE-----'
				[System.Convert]::ToBase64String($cert.RawData) -replace ".{64}" , "$&`r`n"
				'-----END CERTIFICATE-----'
			)
			$content | Out-File -FilePath $certFile -Encoding ascii
			If (!(Test-Path -Path $rootcer)) {
				Write-Host "Root64.cer did not download. Check root CA variable, CA web services, or manually download root cert and copy to $Cert_Dir\root64.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;Exit}
			Write-Host "Root CA download successful." -foregroundcolor yellow
		}
		Else {Write-Host "Root CA file found, will not download." -ForegroundColor yellow} 
	}
	$Validation = select-string -simple CERTIFICATE----- $rootcer
	If (!$Validation) {
		Write-Host "Invalid Root certificate format. Validate BASE64 encoding and try again. Also try decrementing RootRenewal value by 1." -foregroundcolor red; Exit}
	# Download Subordinate CA public certificate, if defined
	# if the certificate exists (interm64.cer) then it won't attempt to download
	If ($SubCA) {
		If (!(Test-Path -Path $intermcer)) {
            $CertThumbprint = (Get-ChildItem Cert:\LocalMachine\CA | Where-Object {$_.Subject -match $subca.split(".")[0] -and $_.SignatureAlgorithm.FriendlyName -match 256} | Sort-Object NotAfter -Descending | Select-Object -first 1).Thumbprint

			$cert = Get-Item -Path cert:\LocalMachine\CA\$CertThumbprint
			$certFile = "$Cert_Dir\interm64.cer"
			$content = @(    
				'-----BEGIN CERTIFICATE-----'
				[System.Convert]::ToBase64String($cert.RawData) -replace ".{64}" , "$&`r`n"
				'-----END CERTIFICATE-----'
			)
			$content | Out-File -FilePath $certFile -Encoding ascii
			If (!(Test-Path -Path $intermcer)) {
				Write-Host "Interm64.cer did not download. Check subordinate variable, CA web services, or manually download intermediate cert and copy to $Cert_Dir\interm64.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;Exit}
			Write-Host "Intermediate CA download successful." -foregroundcolor yellow
		}
		Else { Write-Host "Intermediate CA file found, will not download." -ForegroundColor yellow} 
		
		$Validation = select-string -simple CERTIFICATE----- $intermcer
		If (!$Validation) {
			Write-Host "Invalid subordinate certificate format. Validate BASE64 encoding and try again. Also try decrementing SubRenewal value by 1." -foregroundcolor red; Exit}
	}
	# Download second-level Subordinate CA public certificate, if defined
	# if the certificate exists (interm264.cer) then it won't attempt to download
	If ($SubCA2) {
		If (!(Test-Path -Path $interm2cer)) {
            $CertThumbprint = (Get-ChildItem Cert:\LocalMachine\CA | Where-Object {$_.Subject -match $subca2.split(".")[0] -and $_.SignatureAlgorithm.FriendlyName -match 256} | Sort-Object NotAfter -Descending | Select-Object -first 1).Thumbprint

			$cert = Get-Item -Path cert:\LocalMachine\CA\$CertThumbprint
			$certFile = "$Cert_Dir\interm264.cer"
			$content = @(    
				'-----BEGIN CERTIFICATE-----'
				[System.Convert]::ToBase64String($cert.RawData) -replace ".{64}" , "$&`r`n"
				'-----END CERTIFICATE-----'
			)
			$content | Out-File -FilePath $certFile -Encoding ascii
			If (!(Test-Path -Path $interm2cer)) {
				Write-Host "Interm264.cer did not download. Check subordinate 2 CA variable, CA web services, or manually download intermediate cert and copy to $Cert_Dir\interm264.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;Exit}
			Write-Host "Second Intermediate CA download successful." -foregroundcolor yellow
		}
		Else { Write-Host "Second Intermediate CA file found, will not download." -ForegroundColor yellow} 
		
		$Validation = select-string -simple CERTIFICATE----- $intermcer
		If (!$Validation) {
			Write-Host "Invalid second subordinate certificate format. Validate BASE64 encoding and try again. Also try decrementing Sub2Renewal value by 1." -foregroundcolor red; Exit}
	}
}

function MoveUserCerts {
	Get-ChildItem -Path $Cert_Dir -filter "*.crt" | ForEach-Object {
		$Dir = $_.basename
		If (!(Test-Path $Cert_Dir\$Dir)) {New-Item $Cert_Dir\$Dir -Type Directory}
		move-Item -Path $_.FullName -Destination $Cert_Dir\$Dir -Force
	}
	Get-ChildItem -Path $Cert_Dir -filter "*.key" | ForEach-Object {
		$Dir = $_.basename
		move-Item -Path $_.FullName -Destination $Cert_Dir\$Dir -Force
	}
}

function OnlineMint ($SVCDir, $CSRFile, $CertFile, $Template, $Cert_Dir, $ISSUING_CA) { 
# Mint certificates from online Microsoft CA
    # initialize objects to use for external processes
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $Script:certsWaitingForApproval = $false
        # submit the CSR to the CA
        $psi.FileName = "certreq.exe"
        $psi.Arguments = @("-submit -attrib `"$Template`" -config `"$ISSUING_CA`" -f `"$Cert_Dir\$SVCDir\$CSRFile`" `"$Cert_Dir\$SVCDir\$CertFile`"")
    Write-Host ""
        Write-Host "Submitting certificate request for $SVCDir..." -ForegroundColor Yellow
        [void]$process.Start()
        $cmdOut = $process.StandardOutput.ReadToEnd()
        If ($cmdOut.Trim() -like "*request is pending*")
        {
            # Output indicates the request requires approval before we can download the signed cert.
            $Script:CertsWaitingForApproval = $true
            # So we need to save the request ID to use later once they're approved.
            $reqID = ([regex]"RequestId: (\d+)").Match($cmdOut).Groups[1].Value
            If ($reqID.Trim() -eq [String]::Empty)
            {
                Write-Error "Unable to parse RequestId from output."
                Write-Debug $cmdOut
                Exit
            }
            Write-Host "RequestId: $reqID is pending" -ForegroundColor Yellow
            # Save the request ID to a file that OnlineMintResume can read back in later
            $reqID | out-file "$Cert_Dir\$SVCDir\requestid.txt"
        }
        Else
        {
            # Output doesn't indicate a pending request, so check for a signed cert file
            If (!(Test-Path $Cert_Dir\$SVCDir\$CertFile)) {
                Write-Error "Certificate request failed or was unable to download the signed certificate."
                Write-Error "Verify that the ISSUING_CA variable is set correctly." 
                Write-Debug $cmdOut
                Exit
            }
            else { Write-Host "Certificate successfully downloaded." -ForegroundColor Yellow}
        }
    if ($Script:CertsWaitingForApproval) {
        Write-Host
        Write-Host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host "Contact your CA administrator to approve the request ID(s) listed above." -ForegroundColor Yellow
        Write-Host "To resume use the appropriate option from the menu." -ForegroundColor Yellow
    }
}

function OnlineMintResume ($SVCDir, $CertFile) {
# Resume the minting process for certificates from online Microsoft CA that required approval
    # initialize objects to use for external processes
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $Script:CertsWaitingForApproval = $false
    # skip if there's no requestid.txt file
    If (!(Test-Path "$Cert_Dir\$SVCDir\requestid.txt")) {Continue}
    $reqID = Get-Content "$Cert_Dir\$SVCDir\requestid.txt"
    Write-Verbose "Found RequestId: $reqID for $SVCDir"
    # retrieve the signed certificate
    $psi.FileName = "certreq.exe"
    $psi.Arguments = @("-retrieve -f -config `"$ISSUING_CA`" $reqID `"$Cert_Dir\$SVCDir\$CertFile`"")
    Write-Host "Downloading the signed $SVCDir certificate..." -ForegroundColor Yellow
    [void]$process.Start()
    $cmdOut = $process.StandardOutput.ReadToEnd()
    If (!(Test-Path "$Cert_Dir\$SVCDir\$CertFile")) {
        # it's not there, so check if the request is still pending
        If ($cmdOut.Trim() -like "*request is pending*") {
            $Script:CertsWaitingForApproval = $true
            Write-Host "RequestId: $reqID is pending" -ForegroundColor Yellow
        }
        Else
        {
			Write-Warning "There was a problem downloading the signed certificate" -foregroundcolor red
			Write-Warning $cmdOut
			Continue
        }
    }
    If ($Script:CertsWaitingForApproval) {
        Write-Host
        Write-Host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host "Contact your CA administrator to approve the request IDs listed above." -ForegroundColor Yellow
    }
    $Script:CertsWaitingForApproval = $false
}

# Save Object to yaml file.
function SaveToYaml
{
    Param (
		[Parameter(Mandatory=$true, Position=0)]
		$InputObject,
		[Parameter(Mandatory=$true, Position=1)]
		$FilePath
	)

	removenull $InputObject

	$InputObject | ConvertPSObjectToHashtable | ConvertTo-Yaml | Set-Content -Path $FilePath
}

# Save Object to json file.
function SaveToJson
{
    Param (
		[Parameter(Mandatory=$true, Position=0)]
		$InputObject,
		[Parameter(Mandatory=$true, Position=1)]
		$FilePath
	)

	removenull $InputObject

	$InputObject | ConvertTo-Json | Set-Content -Path $FilePath
}

function Use-Openssl ($OpenSSLArgs) {
	$OpensslInfo = $null
	$o			 = $null
	$OpensslInfo = New-Object System.Diagnostics.ProcessStartInfo
	$OpensslInfo.FileName = $openssl
	$OpensslInfo.RedirectStandardError = $true
	$OpensslInfo.RedirectStandardOutput = $true
	$OpensslInfo.UseShellExecute = $false
	$OpensslInfo.Arguments = $OpenSSLArgs
	$o = New-Object System.Diagnostics.Process
	$o.StartInfo = $OpensslInfo
	$o.Start() | Out-Null
	$o.WaitForExit()
	$stdout = $o.StandardOutput.ReadToEnd()
	$stderr = $o.StandardError.ReadToEnd()
	Write-Host "stdout: $stdout"
	Write-Host "stderr: $stderr"
	Write-Host "exit code: " + $o.ExitCode
}

function TransferCertToNode ($RootCert_Dir, $Cert_Dir, $Deployment, $vihandle, $DeploymentParent) {
	# http://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.security.doc/GUID-BD70615E-BCAA-4906-8E13-67D0DBF715E4.html
	# Copy SSL certificates to a VCSA and replace the existing ones.

	$pscdeployments	= @("tiny","small","medium","large","infrastructure")
	
	$certpath 		= "$Cert_Dir\" + $Deployment.Hostname
	$SslPath		= "/root/ssl"
	$SolutionPath	= "/root/solutioncerts"
	$script 		= "mkdir $SslPath;mkdir $SolutionPath"
	
	ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

	$versionregex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $script | Out-String

	$viversion = $(ExecuteScript $script $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput.Split("") | select-string -pattern $versionregex

	Write-Output $viversion

	$filelocations = $null
	$filelocations = @()
    $filelocations += "$certpath\machine\new_machine.crt"
	$filelocations += "$SslPath/new_machine.crt"
	$filelocations += "$certpath\machine\new_machine.cer"
	$filelocations += "$SslPath/new_machine.cer"
	$filelocations += "$certpath\machine\ssl_key.priv"
	$filelocations += "$SslPath/ssl_key.priv"
	If ($pscdeployments -contains $Deployment.DeployType) {
		If (Test-Path -Path "$RootCert_Dir\root64.cer") {
			$filelocations += "$RootCert_Dir\root64.cer"
			$filelocations += "$SslPath/root64.cer"}
		If (Test-Path -Path "$RootCert_Dir\interm64.cer") {
			$filelocations += "$RootCert_Dir\interm64.cer"
			$filelocations += "$SslPath/interm64.cer"}
		If (Test-Path -Path "$RootCert_Dir\interm264.cer") {
		$filelocations += "$RootCert_Dir\interm264.cer"
		$filelocations += "$SslPath/interm264.cer"}}

	If (Test-Path -Path "$RootCert_Dir\interm64.cer") {
		$filelocations += "$RootCert_Dir\chain.cer"
		$filelocations += "$SslPath/chain.cer"}

	$filelocations += "$certpath\solution\machine.cer"
	$filelocations += "$SolutionPath/machine.cer"
	$filelocations += "$certpath\solution\machine.priv"
	$filelocations += "$SolutionPath/machine.priv"
	$filelocations += "$certpath\solution\vsphere-webclient.cer"
	$filelocations += "$SolutionPath/vsphere-webclient.cer"
	$filelocations += "$certpath\solution\vsphere-webclient.priv"
	$filelocations += "$SolutionPath/vsphere-webclient.priv"
	If ($Deployment.DeployType -ne "Infrastructure") {
		$filelocations += "$certpath\solution\vpxd.cer"
		$filelocations += "$SolutionPath/vpxd.cer"
		$filelocations += "$certpath\solution\vpxd.priv"
		$filelocations += "$SolutionPath/vpxd.priv"
		$filelocations += "$certpath\solution\vpxd-extension.cer"
		$filelocations += "$SolutionPath/vpxd-extension.cer"
		$filelocations += "$certpath\solution\vpxd-extension.priv"
		$filelocations += "$SolutionPath/vpxd-extension.priv"}

	CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle $true

	$commandlist = $null
	$commandlist = @()

	# Set path for python.
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"	
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	# Stop all services.
	$commandlist += "service-control --stop --all"
	# Start vmafdd,vmdird, and vmca services.
	$commandlist += "service-control --start vmafdd"
	If ($pscdeployments -contains $Deployment.DeployType) {
		$commandlist += "service-control --start vmdird"
		$commandlist += "service-control --start vmca"
	}

	# Replace the root cert.
	If ($pscdeployments -contains $Deployment.DeployType) {
		If (Test-Path -Path "$RootCert_Dir\root64.cer") {
			$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/root64.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}
		If (Test-Path -Path "$RootCert_Dir\interm64.cer") {	
			$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/interm64.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}
		If (Test-Path -Path "$RootCert_Dir\interm264.cer") {	
			$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/interm264.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}}

	# Add certIficate chain to TRUSTED_ROOTS of the PSC for ESXi Cert Replacement.
	# If ($pscdeployments -contains $Deployment.DeployType -and (Test-Path -Path "$RootCert_Dir\interm64.cer")) {
	<#If ($Deployment.DeployType -eq "Infrastructure" -and (Test-Path -Path "$RootCert_Dir\interm64.cer")) {
		$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry create --store TRUSTED_ROOTS --alias chain.cer --cert $SslPath/chain.cer"
	}#>

	# Retrive the Old Machine Cert and save its thumbprint to a file.
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store MACHINE_SSL_CERT --alias __MACHINE_CERT --output $SslPath/old_machine.crt"
	$commandlist += "openssl x509 -in $SslPath/old_machine.crt -noout -sha1 -fingerprint > $SslPath/thumbprint.txt"

    # Replace the Machine Cert.
	$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store MACHINE_SSL_CERT --alias __MACHINE_CERT"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store MACHINE_SSL_CERT --alias __MACHINE_CERT --cert $SslPath/new_machine.cer --key $SslPath/ssl_key.priv"

	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

	$commandlist = $null
	$commandlist = @()
	$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vsphere-webclient --alias vsphere-webclient"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vsphere-webclient --alias vsphere-webclient --cert $SolutionPath/vsphere-webclient.cer --key $SolutionPath/vsphere-webclient.priv"
	# Skip If server is an External PSC. - vpxd and vpxd-extension do not need to be replaced on an external PSC.
	If ($Deployment.DeployType -ne "Infrastructure"){
		$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd --alias vpxd"
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd --alias vpxd --cert $SolutionPath/vpxd.cer --key $SolutionPath/vpxd.priv"
		$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd-extension --alias vpxd-extension"	
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd-extension --alias vpxd-extension --cert $SolutionPath/vpxd-extension.cer --key $SolutionPath/vpxd-extension.priv"	
	}

	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
	
	$commandlist = $null
	$commandlist = @()
	$commandlist += "/usr/lib/vmware-vmafd/bin/vmafd-cli get-machine-id --server-name localhost"
	$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli service list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
	
	$UniqueID = Invoke-VMScript -ScriptText $commandlist[0] -vm $Deployment.Hostname -GuestUser "root" -GuestPassword $Deployment.VCSARootPass -Server $vihandle
	$CertList = Invoke-VMScript -ScriptText $commandlist[1] -vm $Deployment.Hostname -GuestUser "root" -GuestPassword $Deployment.VCSARootPass -Server $vihandle

	Separatorline

	Write-Output "Unique ID: " + $UniqueID | Out-String
	Write-Output "Certificate List: " + $CertList | Out-String

	Separatorline
	
	# Retrieve unique key list relevant to the server.
	$SolutionUsers = ($Certlist.ScriptOutput.split(".").Split("`n") | ForEach-Object {If($_[0] -eq " "){$_}} | Where-Object {$_.ToString() -like "*$($UniqueID.ScriptOutput.split("`n")[0])*"}).Trim(" ")

	Separatorline

	Write-Output "Solution Users: " + $SolutionUsers | Out-String

	Separatorline

	$commandlist = $null
	$commandlist = @()

	$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[1] + " --cert $SolutionPath/vsphere-webclient.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
	If ($Deployment.DeployType -ne "Infrastructure") {
		$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[2] + " --cert $SolutionPath/vpxd.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
		$commandlist += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[3] + " --cert $SolutionPath/vpxd-extension.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}
		
	# Set path for python.
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"	
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	# Start all services.
	$commandlist += "service-control --start --all --ignore"
	
	# Service update
	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

	Start-Sleep -Seconds 10

	If ($Deployment.DeployType -ne "Infrastructure"){
		$commandlist = $null
		$commandlist = @()
		# Set path for python.
		$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$commandlist += "export VMWARE_LOG_DIR=/var/log"
		$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
		$commandlist += "export VMWARE_DATA_DIR=/storage"
		# Replace EAM Solution User Cert.
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.crt"
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getkey --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.key"
		$commandlist += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.vim.eam -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s " + $Deployment.Hostname + " -u administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`'"
		$commandlist += '/usr/bin/service-control --stop vmware-eam'
		$commandlist += '/usr/bin/service-control --start vmware-eam'

		# Service update
		ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
	}

    # Update VAMI Certs on External PSC.
	$commandlist = $null
	$commandlist = @()
   	$commandlist += "/usr/lib/applmgmt/support/scripts/postinstallscripts/setup-webserver.sh"

	# Service update
	ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle

    # Refresh Update Manager CertIficates.
	If ($viversion -match "6.5." -and $Deployment.DeployType -ne "Infrastructure") {
    	$commandlist = $null
		$commandlist = @()
		# Set path for python.
		$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$commandlist += "export VMWARE_LOG_DIR=/var/log"	
		$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
		$commandlist += "export VMWARE_DATA_DIR=/storage"
		$commandlist += "export VMWARE_RUNTIME_DATA_DIR=/var"
    	$commandlist += "/usr/lib/vmware-updatemgr/bin/updatemgr-util refresh-certs"
    	$commandlist += "/usr/lib/vmware-updatemgr/bin/updatemgr-util register-vc"		


    	# Service update
		ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
	}

    # Refresh Update Manager CertIficates.
	If ($viversion -match "6.7." -and $Deployment.DeployType -ne "Infrastructure") {

		$script = "echo `'$Deployment.VCSARootPass`' | appliancesh com.vmware.updatemgr-util register-vc"

    	# Service update
		ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
	}

 	# Assign the original machine certIficate thumbprint to $thumbprint and remove the carriage return.
    # Change the shell to Bash to enable scp and retrieve the original machine certIficate thumbprint.
    $commandlist = $null
    $commandlist = @()
    $commandlist += "chsh -s /bin/bash"
    $commandlist += "cat /root/ssl/thumbprint.txt"
    $thumbprint = $(ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle).Scriptoutput.Split("=",2)[1] 
	$thumbprint = $thumbprint -replace "`t|`n|`r",""

    # Register new certIficates with VMWare Lookup Service - KB2121701 and KB2121689.
	If ($pscdeployments -contains $Deployment.DeployType) {
        # Register the new machine thumbprint with the lookup service.
        $commandlist = $null
        $commandlist = @()
		# Set path for python.
        $commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandlist += "export VMWARE_LOG_DIR=/var/log"
        $commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandlist += "export VMWARE_DATA_DIR=/storage"
		$commandlist += "export VMWARE_JAVA_HOME=/usr/java/jre-vmware"
		# Register the new machine thumprint.
        $commandlist += "python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $Deployment.Hostname + "/lookupservice/sdk --fingerprint $thumbprint --certfile /root/ssl/new_machine.crt --user administrator@" + $Deployment.SSODomainName + " --password `'" + $Deployment.SSOAdminPass + "`'"

        Write-Output $commandlist | Out-String
        
        ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle}
    Else {
		  # If the VCSA vCenter does not have an embedded PSC Register its Machine CertIficate with the External PSC.
          Write-Output $DeploymentParent | Out-String
          
          # SCP the new vCenter machine certIficate to the external PSC and register it with the VMWare Lookup Service via SSH.
              $commandlist = $null
              $commandlist = @()
              $commandlist += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' scp -oStrictHostKeyChecking=no /root/ssl/new_machine.crt root@" + $DeploymentParent.Hostname + ":/root/ssl/new_" + $Deployment.Hostname + "_machine.crt"
              $commandlist += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $DeploymentParent.Hostname + " `"python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $DeploymentParent.Hostname + "/lookupservice/sdk --fingerprint $thumbprint --certfile /root/ssl/new_" + $Deployment.Hostname + "_machine.crt --user administrator@" + $DeploymentParent.SSODomainName + " --password `'" + $DeploymentParent.SSOAdminPass + "`'`""

              Write-Output $commandlist | Out-String

              ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $vihandle
    }

}

function UserPEMFiles {
	# Creates PEM files for all solution user certificates
	Get-ChildItem -Path $Cert_Dir -filter "*.csr" | ForEach-Object {
		$Dir = $_.basename
		CreatePEMFiles $Dir "$Dir.crt" "$Dir.cer"
	}
  
}

function VMDirRename ($Cert_Dir) {
	# Renames SSL certificate files to those used by VCSA
	Rename-Item $Cert_Dir\VMDir\VMDir.cer vmdircert.pem
	Rename-Item $Cert_Dir\VMDir\VMDir.priv vmdirkey.pem
	Write-Host "Certificate files renamed. Upload \VMDir\vmdircert.pem and \VMDir\vmdirkey.pem" -ForegroundColor Yellow
	Write-Host "to VCSA at /usr/lib/vmware-dir/share/config" -ForegroundColor Yellow
}

function VMCAMint ($SVCDir, $CFGFile, $CertFile, $PrivFile) {
	# This function issues a new SSL certificate from the VMCA.
	If(!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$MachineFQDN = $(
		Write-Host "Do you want to replace the SSL certificate on $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		If ($InputFQDN) {$InputFQDN} Else {$DEFFQDN}
	)
	$PSCFQDN = $(
		Write-Host "Is the PSC $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input the correct PSC FQDN"
		If ($InputFQDN) {$InputFQDN} Else {$DEFFQDN}
	)
	$MachineIP = [System.Net.Dns]::GetHostAddresses("$MachineFQDN").IPAddressToString -like '*.*'
	Write-Host $MachineIP
	$VMWTemplate = "
	#
	# Template file for a CSR request
	#
	# Country is needed and has to be 2 characters
	Country = $Country
	Name = $CompanyName
	Organization = $OrgName
	OrgUnit = $OrgUnit
	State = $State
	Locality = $Locality
	IPAddress = $MachineIP
	Email = $email
	Hostname = $MachineFQDN
	"
	$Out = $VMWTemplate | Out-File "$Cert_Dir\$SVCDir\$CFGFile" -Encoding Default -Force
	# Mint certificate from VMCA and save to disk
	Set-Location "C:\Program Files\VMware\vCenter Server\vmcad"
	.\certool --genkey --privkey=$Cert_Dir\$SVCDir\$PrivFile --pubkey=$Cert_Dir\$SVCDir\$SVCDir.pub
	.\certool --gencert --cert=$Cert_Dir\$SVCDir\$CertFile --privkey=$Cert_Dir\$SVCDir\$PrivFile --config=$Cert_Dir\$SVCDir\$CFGFile --server=$PSCFQDN
	If (Test-Path $Cert_Dir\$SVCDir\$CertFile) {Write-Host "PEM file located at $Cert_Dir\$SVCDir\new_machine.cer" -ForegroundColor Yellow n}
}

function CDDir ($FolderPath) {
	# CDs into the directory the Toolkit script was run
	Set-Location $FolderPath
}

function CreateVCSolutionCert ($RootCert_Dir, $Cert_Dir, $InstanceCertDir, $Certinfo) {
	CreateSolutionCSR Solution vpxd.csr vpxd.cfg vpxd.priv 6 vpxd $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vpxd-extension.csr vpxd-extension.cfg vpxd-extension.priv 6 vpxd-extension $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo
	
	OnlineMint Solution vpxd.csr vpxd.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vpxd-extension.csr vpxd-extension.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution machine.csr machine.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	
	CreatePEMFiles Solution vpxd.crt vpxd.cer $RootCert_Dir $InstanceCertDir
	CreatePEMFiles Solution vpxd-extension.crt vpxd-extension.cer $RootCert_Dir $InstanceCertDir
	CreatePEMFiles Solution machine.crt machine.cer $RootCert_Dir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $RootCert_Dir $InstanceCertDir
}

function CreatePscSolutionCert ($RootCert_Dir, $Cert_Dir, $InstanceCertDir, $Certinfo) {
	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo

	OnlineMint Solution machine.csr machine.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	
	CreatePEMFiles Solution machine.crt machine.cer $RootCert_Dir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $RootCert_Dir $InstanceCertDir
}

# End Functions

# PSScriptRoot does not have a trailing "\"
Write-Output $FolderPath | Out-String

# Start New Transcript
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Continue"
$LogPath = "$FolderPath\Logs\" + $(Get-date -format "MM-dd-yyyy_HH-mm")
If (!(Test-Path $LogPath)) {New-Item $LogPath -Type Directory}
$OutputPath = "$LogPath\InitialState_" + $(Get-date -format "MM-dd-yyyy_HH-mm") + ".log"
Start-Transcript -path $OutputPath -append

Separatorline

# Check to see if Powershell is at least version 3.0
$PSpath = "HKLM:\SOFTWARE\Microsoft\PowerShell\3"
If (!(Test-Path $PSpath)) {
	Write-Host "PowerShell 3.0 or higher required. Please install"; Exit 
}

# Load Powercli Modules
If (get-module -ListAvailable | Where-Object {$_.Name -match "VMware.PowerCLI"}) {
	import-module VMware.PowerCLI
}
Else {
		If (get-command Install-module -ErrorAction SilentlyContinue) {
			Install-Module -Name VMware.PowerCLI -Confirm:$false
		}
		Else 
		{Exit}
}

If (get-module -ListAvailable | Where-Object {$_.Name -match "powershell-yaml"}) {
	import-module powershell-yaml
}
Else {
		If (get-command Install-module -ErrorAction SilentlyContinue) {
			Install-Module -Name powershell-yaml -Confirm:$false
		}
		Else 
		{Exit}
}

Separatorline

# Check the version of Ovftool and get it's path. Search C:\program files\ and C:\Program Files (x86)\ subfolders for vmware and find the
# Ovftool folders. Then check the version and return the first one that is version 4 or higher.
$OvfToolPath = (Get-ChildItem (Get-ChildItem $env:ProgramFiles, ${env:ProgramFiles(x86)} -filter vmware).fullname -recurse -filter ovftool.exe | ForEach-Object {If(!((& $($_.DirectoryName + "\ovftool.exe") --version).split(" ")[2] -lt 4.0.0)){$_}} | Select-Object -first 1).DirectoryName

# Check ovftool version
if (!$OvfToolPath) 
	{Write-Host "Script requires installation of ovftool 4.0.0 or newer";
	 Exit} 
Else
	{Write-Host "ovftool version OK `r`n"}
	
# ---------------------  Load Parameters from Excel ------------------------------

### Load from Excel
Switch ($Source) {
	'excel' {
			# Source Excel Path
			$ExcelFilePathSrc = "$FolderPath\$ExcelFileName"
			
			# Create an Object Excel.Application using Com interface
			$objExcel = New-Object -ComObject Excel.Application
			
			# Disable the 'visible' property so the document won't open in excel
			$objExcel.Visible = $false
			
			# Open the Excel file and save it in $WorkBook
			$workBook 	= $objExcel.Workbooks.Open($ExcelFilePathSrc)
			
			# get ad info
			$workSheet	= $WorkBook.sheets.item("adinfo")
			$lastrow	= $worksheet.Range("A:A").count
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			### Get Excel
			If ($rows -gt 1 -and $rows -lt $lastrow) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data 		= $Worksheet.Range("A2","F$rows").Value()
				$s_plugins	= @()
				For ($i=1;$i -lt $rows;$i++) {
					$s_plugin  = [PSCustomObject]@{
						Config 			= $data[$i,1]
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data	  = $Worksheet.Range("A2","K$rows").Value()
				$s_arules = @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","R$rows").Value().split("`n")
				$s_Certinfo = [PSCustomObject]@{
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
				
				If ($s_Certinfo.SubCA1 -eq "null") {$s_Certinfo.SubCA1 = $null}
				If ($s_Certinfo.SubCA2 -eq "null") {$s_Certinfo.SubCA2 = $null}
			}
			
			# get clusters
			$workSheet	= $WorkBook.sheets.item("clusters")
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data 		= $Worksheet.Range("A2","C$rows").Value()
				$s_clusters = @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","F$rows").Value()
				$s_folders	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data			= $Worksheet.Range("A2","G$rows").Value()
				$s_Permissions	= @()
				For ($i=1;$i -lt $rows;$i++) {
					$s_Permission  = [PSCustomObject]@{
						Entity		= $data[$i,1]
						Location	= $data[$i,2]
						Principal	= $data[$i,3]
						Group		= $data[$i,4]	
						Propagate	= $data[$i,5]	
						Role		= $data[$i,6]
						vCenter		= $data[$i,7]
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
				
				For ($i=1;$i -lt $rows;$i++) {
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
						ChangeSid				= $data[$i,14]
						DeleteAccounts			= $data[$i,15]
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
			$workSheet		= $WorkBook.sheets.item("vcsa")
			$rows			= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data			= $Worksheet.Range("A2","AA$rows").Value()
				$s_Deployments	= @()
				For ($i=1;$i -lt $rows;$i++) {
					$s_Deployment  = [PSCustomObject]@{
						Action			= $data[$i,1]
						Config			= $data[$i,2]
						Certs			= $data[$i,3]
						vmName			= $data[$i,4]
						Hostname		= $data[$i,5]
						VCSARootPass	= $data[$i,6]
						NetMode			= $data[$i,7]
						NetFamily		= $data[$i,8]	
						NetPrefix		= $data[$i,9]
						JumboFrames		= $data[$i,10]
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
						OVA				= "$FolderPath\$($data[$i,27])"
					}
					$s_Deployments += $s_Deployment
				}
			}

			# get Licenses
			$workSheet	= $WorkBook.sheets.item("licenses")
			$rows		= $objExcel.Worksheetfunction.Countif($worksheet.Range("A:A"),"<>")
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","D$rows").Value()
				$s_Licenses	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","C$rows").Value()
				$s_Roles	= @()
				For ($i=1;$i -lt $rows;$i++){
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","B$rows").Value()
				$s_Services	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data 		= $Worksheet.Range("A2","E$rows").Value()
				$s_sites	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data 			= $Worksheet.Range("A2","E$rows").Value()
				$s_vdswitches	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
			
			If ($rows -gt 1 -and $rows -lt $lastrow) {
				$data		= $Worksheet.Range("A2","F$rows").Value()
				$s_vlans 	= @()
				For ($i=1;$i -lt $rows;$i++) {
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
                TranscriptScrub = $Worksheet.Range("A2","A2").Value()
            }
            
            $workbook.Close($false)
			$objExcel.Quit()

			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($worksheet)
			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workbook)
			[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($objExcel)

			$workSheet	= $null
			$workbook	= $null
			$objExcel	= $null

			[System.GC]::Collect()
			[System.GC]::WaitForPendingFinalizers()
		}
	
	'json' { 	
			$Json_Dir = $FolderPath + "\Json"
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
		
	'yaml' {
			$Yaml_Dir = $FolderPath + "\Yaml"
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

            # Change ":" Colon to commas for Vlan Network Properties.
			For ($i=0;$i -lt ($s_vlans | Measure-Object).count;$i++) {
				$s_vlans[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
			}
		}
}

Write-Output $s_adinfo          | Out-String
Separatorline
Write-Output $s_plugins         | Out-String
Separatorline
Write-Output $s_arules          | Out-String
Separatorline
Write-Output $s_Certinfo        | Out-String
Separatorline
Write-Output $s_clusters        | Out-String
Separatorline
Write-Output $s_folders         | Out-String
Separatorline
Write-Output $s_Permissions     | Out-String
Separatorline
Write-Output $s_Customizations  | Out-String
Separatorline
Write-Output $s_Deployments     | Out-String
Separatorline
Write-Output $s_Licenses        | Out-String
Separatorline
Write-Output $s_Roles           | Out-String
Separatorline
Write-Output $s_Services        | Out-String
Separatorline
Write-Output $s_sites           | Out-String
Separatorline
Write-Output $s_vdswitches      | Out-String
Separatorline
Write-Output $s_vlans           | Out-String
Separatorline
Write-Output $s_summary         | Out-String
Separatorline

# Password Scrub array for redacting passwords from Transcript.
If ($s_summary.TranscriptScrub) {
    $scrub = @()
    $scrub += $s_adinfo.ADJoinPass
    $scrub += $s_adinfo.ADvmcamPass
    $scrub += $s_arules.ProfileRootPassword
	$scrub += $s_Customizations.AdminPassword
	$scrub += $s_Customizations.DomainPassword
    $scrub += $s_Deployments.VCSARootPass
    $scrub += $s_Deployments.esxiRootPass
    $scrub += $s_Deployments.SSOAdminPass
}

### Save to Excel
If ($Source -ne 1 -and $Export) {
	$ExcelFilePathDst = "$FolderPath\$ExcelFileName"
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
	$objExcelDst.ActiveWorkbook.SaveAs($ExcelFilePathDst,$xlFixedFormat,1)
	$workBookDst.Close($false)
	$objExcelDst.Quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()

	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workBookDst)
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($objExcelDst)
}

### Save to Json
If ($Source -ne 2 -and $Export) {
	If (!(Test-Path -Path "$FolderPath\Json")) {New-Item "$FolderPath\Json" -Type Directory}
	SaveToJson -InputObject $s_adinfo -FilePath "$FolderPath\ad-info.json"
	SaveToJson -InputObject $s_plugins -FilePath "$FolderPath\plugins.json"
	SaveToJson -InputObject $s_arules -FilePath "$FolderPath\autodeploy-rules.json"
	SaveToJson -InputObject $s_Certinfo -FilePath "$FolderPath\cert-info.json"
	SaveToJson -InputObject $s_clusters -FilePath "$FolderPath\cluster-info.json"
	SaveToJson -InputObject $s_folders -FilePath "$FolderPath\folders.json"
	SaveToJson -InputObject $s_Permissions -FilePath "$FolderPath\permissions.json"
	SaveToJson -InputObject $s_Customizations -FilePath "$FolderPath\os-customizations.json"
	SaveToJson -InputObject $s_Deployments -FilePath "$FolderPath\deployments.json"
	SaveToJson -InputObject $s_Licenses -FilePath "$FolderPath\licenses.json"
	SaveToJson -InputObject $s_Roles -FilePath "$FolderPath\roles.json"
    SaveToJson -InputObject $s_Services -FilePath "$FolderPath\services.json"
    SaveToJson -InputObject $s_sites -FilePath "$FolderPath\sites.json"
    SaveToJson -InputObject $s_vdswitches -FilePath "$FolderPath\vdswitches.json"
    SaveToJson -InputObject $s_vlans -FilePath "$FolderPath\vlans.json"
    SaveToJson -InputObject $s_summary -FilePath "$FolderPath\summary.json"
}

### Save to Yaml
If ($Source -ne 3 -and $Export) {
	If (!(Test-Path -Path "$FolderPath\Yaml")) {New-Item "$FolderPath\Yaml" -Type Directory}
	SaveToYaml -InputObject $s_adinfo -FilePath "$FolderPath\ad-info.yml"
	SaveToYaml -InputObject $s_plugins -FilePath "$FolderPath\plugins.yml"
	SaveToYaml -InputObject $s_arules -FilePath "$FolderPath\autodeploy-rules.yml"
	SaveToYaml -InputObject $s_Certinfo -FilePath "$FolderPath\cert-info.yml"
	SaveToYaml -InputObject $s_clusters -FilePath "$FolderPath\cluster-info.yml"
	SaveToYaml -InputObject $s_folders -FilePath "$FolderPath\folders.yml"
	SaveToYaml -InputObject $s_Permissions -FilePath "$FolderPath\permissions.yml"
	SaveToYaml -InputObject $s_Customizations -FilePath "$FolderPath\os-customizations.yml"
	SaveToYaml -InputObject $s_Deployments -FilePath "$FolderPath\deployments.yml"
	SaveToYaml -InputObject $s_Licenses -FilePath "$FolderPath\licenses.yml"
	SaveToYaml -InputObject $s_Roles -FilePath "$FolderPath\roles.yml"
	SaveToYaml -InputObject $s_Services -FilePath "$FolderPath\services.yml"
	SaveToYaml -InputObject $s_sites -FilePath "$FolderPath\sites.yml"
	SaveToYaml -InputObject $s_vdswitches -FilePath "$FolderPath\vdswitches.yml"

    # Change commas to ":" Colon for Vlan Network Properties.
	For ($i=0;$i -lt ($s_vlans | Measure-Object).count;$i++) {
		$s_vlans[$i].psobject.properties | Where-Object {If ($_.name -eq "network") {$commacorrect = $_.value -replace ",",':'; $_.value = $commacorrect}}
	}

	SaveToYaml -InputObject $s_vlans -FilePath "$FolderPath\vlans.yml"
    
    # Change ":" Colon to commas for Vlan Network Properties.
	For ($i=0;$i -lt ($s_vlans | Measure-Object).count;$i++) {
		$s_vlans[$i].psobject.properties | Where-Object {If ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
	}

    SaveToYaml -InputObject $s_summary -FilePath "$FolderPath\summary.yml"
}

ReplaceNull $s_adinfo
ReplaceNull $s_plugins
ReplaceNull $s_arules
ReplaceNull $s_Certinfo
ReplaceNull $s_clusters
ReplaceNull $s_folders
ReplaceNull $s_Permissions
ReplaceNull $s_Customizations
ReplaceNull $s_Deployments
ReplaceNull $s_Licenses
ReplaceNull $s_Roles
ReplaceNull $s_Services
ReplaceNull $s_sites
ReplaceNull $s_vdswitches
ReplaceNull $s_vlans
ReplaceNull $s_summary

# ---------------------  END Load Parameters from Excel ------------------------------

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

# Download OpenSSL if it's not already installed
If (!($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"})) {
	$uri = "https://slproweb.com/products/Win32OpenSSL.html"
	$downloadref = ((Invoke-WebRequest -uri $uri).Links | Where-Object {$_.outerHTML -like "*Win64OpenSSL_*"} | Select-Object -first 1).href.split("/")[2]
	Write-Host -Foreground "DarkBlue" -Background "White" "Downloading OpenSSL $downloadref ..."
	$null = New-Item -Type Directory $s_Certinfo.openssldir -erroraction silentlycontinue
	$sslurl = "http://slproweb.com/download/$downloadref"
	$sslexe = "$env:temp\openssl.exe"
	$wc 							= New-Object System.Net.WebClient
	$wc.UseDefaultCredentials 		= $true
	$wc.DownloadFile($sslurl,$sslexe)
	$env:path = $env:path + ";$($s_Certinfo.openssldir)"
    If (!(test-Path($sslexe))) { Write-Host -Foreground "red" -Background "white" "Could not download or find OpenSSL. Please install the latest $downloadref manually or update download name."; Exit}
	Write-Host -Foreground "DarkBlue" -Background "White" "Installing OpenSSL..."
    cmd /c $sslexe /DIR="$($s_Certinfo.openssldir)" /silent /verysilent /sp- /suppressmsgboxes
	Remove-Item $sslexe
}

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

$openssl = ($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"}).InstallLocation + "bin\openssl.exe"

# Check for openssl
CheckOpenSSL $openssl

Separatorline

# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
$netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

If($netAssembly)
{
    $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
    $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

    $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

    If($instance)
    {
        $bindingFlags = "NonPublic","Instance"
        $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

        If($useUnsafeHeaderParsingField)
        {
          $useUnsafeHeaderParsingField.SetValue($instance, $true)
        }
    }
}

# Global variables
$pscdeployments				= @("tiny","small","medium","large","infrastructure")
$mtu						= "9000"

# Certificate variables	
# Create the RANDFILE environmental parameter for openssl to fuction properly.
$env:RANDFILE 		= "$FolderPath\Certs\.rnd"
$rootcer			= "$FolderPath\Certs\root64.cer"
$intermcer 			= "$FolderPath\Certs\interm64.cer" 
$interm2cer 		= "$FolderPath\Certs\interm264.cer" 
$RootCert_Dir		= $FolderPath + "\Certs"
$Script:CertsWaitingForApproval = $false
New-Alias -Name OpenSSL $openssl

Stop-Transcript

# Deploy the VCSA servers.
ForEach ($Deployment in $s_Deployments | Where-Object {$_.Action -notmatch "null|false"}) {
	# Skip deployment if set to null.

	$OutputPath = "$LogPath\Deploy-" + $Deployment.Hostname + "-" + $(Get-date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting deployment of $($Deployment.vmName) ===============" | Out-String
	
	# Deploy the vcsa
	Deploy $Deployment $OvfToolPath $LogPath

	# Write separator line to transcript.
	Separatorline
	
	# Create esxi credentials.
	$esxi_secpasswd		= $null
	$esxi_creds			= $null
	$esxi_secpasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$esxi_creds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $esxi_secpasswd)
	
	# Connect to esxi host of the deployed vcsa.
	$esxihandle = connect-viserver -server $Deployment.esxiHost -credential $esxi_creds
	
	Separatorline

	$commandlist = $null
	$commandlist = @()
	$commandlist += 'test -e "/var/log/firstboot/succeeded"'
	$commandlist += 'echo $?'

	Write-Output "== Firstboot process could take 10+ minutes to complete. please wait. ==" | Out-String

	If (!$stopwatch) {
		$stopwatch =  [system.diagnostics.stopwatch]::StartNew()}
	  Else {$stopwatch.start()}
	  
	  While ((ExecuteScript $commandlist $Deployment.Hostname "root" $($Deployment.VCSARootPass) $esxihandle).ScriptOutput[0] -eq "1") {
	
	  	Start-Sleep -s 15
	  
	  	$elapsed = $stopwatch.Elapsed.ToString('hh\:mm\:ss')
	  
		Write-Progress -Activity "Completing Firstboot for $($Deployment.Hostname)" -Status "Time Elapsed $elapsed"
		
		Write-Output "Time Elapsed completing Firstboot for $($Deployment.Hostname): $elapsed" | Out-String
	
	}
	
	$stopwatch.reset()

       # Enable Jumbo Frames on eth0 if True.
       If ($Deployment.JumboFrames) {
           $commandlist = $null
	    $commandlist = @()
		$commandlist += 'echo -e "" >> /etc/systemd/network/10-eth0.network'
		$commandlist += 'echo -e "[Link]" >> /etc/systemd/network/10-eth0.network'
		$commandlist += 'echo -e "MTUBytes=9000" >> /etc/systemd/network/10-eth0.network'

           ExecuteScript $commandlist $Deployment.vmName "root" $Deployment.VCSARootPass $esxihandle
       }

	Write-Output "`r`n The VCSA $($Deployment.Hostname) has been deployed and is available.`r`n" | Out-String

	# Create certificate directory if it does not exist
	$Cert_Dir			 = $RootCert_Dir + "\" + $Deployment.SSODomainName
	$DefaultRootCert_Dir = 	$Cert_Dir + "\" + $Deployment.Hostname + "\DefaultRootCert"
	If (!(Test-Path $DefaultRootCert_Dir)) { New-Item $DefaultRootCert_Dir -Type Directory | Out-Null }

	InstallNodeRootCert $DefaultRootCert_Dir $Deployment $esxihandle

	# Disconnect from the vcsa deployed esxi server.
	Disconnect-viserver -Server $esxihandle -Confirm:$false

	# Write separator line to transcript.
	Separatorline

	write-host "=============== End of Deployment for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

# Replace Certificates.
ForEach ($Deployment in $s_Deployments | Where-Object {$_.Certs}) {

	$OutputPath = "$LogPath\Certs-" + $Deployment.Hostname + "-" + $(Get-date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting replacement of Certs on $($Deployment.vmName) ===============" | Out-String

	# Wait until the vcsa is available.
	Available $("https://" + $Deployment.Hostname)
	
	# Set $Cert_Dir
	$Cert_Dir = $RootCert_Dir + "\" + $Deployment.SSODomainName
	
	If ($s_Certinfo) {
		# Create esxi credentials.
        $esxi_secpasswd		= $null
		$esxi_creds			= $null
		$esxi_secpasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
		$esxi_creds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $esxi_secpasswd)
	
		# Connect to esxi host of the deployed vcsa.
		$esxihandle = connect-viserver -server $Deployment.esxiHost -credential $esxi_creds

        #ConfigureCertPairs $Cert_Dir $Deployment $esxihandle

		# Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
		$s_certinfo.CompanyName = $Deployment.Hostname
		
		# $InstanceCertDir is the script location plus cert folder and hostname eg. C:\Script\Certs\SSODomain\vm-host1.companyname.com\
		$InstanceCertDir = $Cert_Dir + "\" + $Deployment.Hostname
		
		# Check for or download root certificates.
		DownloadRoots $RootCert_Dir	$s_certinfo.RootCA $rootcer $s_certinfo.SubCA1 $intermcer $s_certinfo.SubCA2 $interm2cer $s_certinfo.CADownload
		
		# Check for or create certificate chain.
		ChainCAs $RootCert_Dir $rootcer $intermcer $interm2cer
		
		# Create the Machine cert.
		CreateCSR machine machine_ssl.csr machine_ssl.cfg ssl_key.priv 6 $InstanceCertDir $s_certinfo
		OnlineMint machine machine_ssl.csr new_machine.crt $s_certinfo.V6Template $InstanceCertDir $s_certinfo.IssuingCA
		CreatePEMFiles machine new_machine.crt new_machine.cer $RootCert_Dir $InstanceCertDir
		
		# Change back to the script root folder.
		CDDir $FolderPath

		# Create the VMDir cert.
		CreateCSR VMDir VMDir.csr VMDir.cfg VMDir.priv 6 $InstanceCertDir $s_certinfo
		OnlineMint VMDir VMDir.csr VMDir.crt $s_certinfo.V6Template $InstanceCertDir $s_certinfo.IssuingCA
		CreatePEMFiles VMDir VMDir.crt VMdir.cer $RootCert_Dir $InstanceCertDir
		
		# Rename the VMDir cert for use on a VMSA.
		VMDirRename $InstanceCertDir
		
		# Change back to the script root folder.		
		CDDir $FolderPath

        $SSOParent = $null
        $SSOParent = $s_Deployments | Where-Object {$Deployment.Parent -eq $_.Hostname}

		# Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
		If ($Deployment.DeployType -eq "infrastructure" ) {
			CreatePscSolutionCert $RootCert_Dir $Cert_Dir $InstanceCertDir $s_certinfo
			Separatorline
            # Copy Cert files to vcsa Node and deploy them.
            TransferCerttoNode $RootCert_Dir $Cert_Dir $Deployment $esxihandle $SSOParent
		}
		Else {CreateVCSolutionCert $RootCert_Dir $Cert_Dir $InstanceCertDir $s_certinfo
			  Separatorline
              # Copy Cert files to vcsa Node and deploy them.
              TransferCerttoNode $RootCert_Dir $Cert_Dir $Deployment $esxihandle $SSOParent

			  # Configure Autodeploy and replace the solution user certificates, and update the thumbprint to the new machine ssl thumbprint.
			  # https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988
              If (($s_Services | Where-Object {($_.vCenter.split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AutoDeploy"}).Service) {
				  $commandlist = $null
				  $commandlist = @()
				  # Set path for python.
				  $commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $commandlist += "export VMWARE_LOG_DIR=/var/log"
				  $commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
				  $commandlist += "export VMWARE_DATA_DIR=/storage"
				  # Configure Autodeploy to automatic start and start the service.
				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
 				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"
				  # Replace the solution user cert for Autodeploy.
				  $commandlist += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				  # Configure imagebuilder and start the service.
				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"
				  # Replace the imagebuilder solution user cert.
				  $commandlist += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.imagebuilder -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				  ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle
				  
				  # Get the new machine cert thumbprint.
				  $commandlist = $null
				  $commandlist = @()
				  $commandlist += "openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint"
				  $newthumbprint = $(ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle).Scriptoutput.Split("=",2)[1]
				  $newthumbprint = $newthumbprint -replace "`t|`n|`r",""
				  
				  # Replace the autodeploy cert thumbprint.
				  $commandlist = $null
				  $commandlist = @()
				  # Set path for python.
				  $commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $commandlist += "export VMWARE_LOG_DIR=/var/log"
				  $commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
				  $commandlist += "export VMWARE_DATA_DIR=/storage"
				  # Stop the autodeploy service.
				  $commandlist += "/usr/bin/service-control --stop vmware-rbd-watchdog"
				  # Replace the thumbprint.
				  $commandlist += "autodeploy-register -R -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -s `"/etc/vmware-rbd/autodeploy-setup.xml`" -f -T $newthumbprint"
				  # Start the autodeploy service.
				  $commandlist += "/usr/bin/service-control --start vmware-rbd-watchdog"
				  ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle
				}
			  If (($s_Services | Where-Object {($_.vCenter.split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AuthProxy"}).Service) {
				  # Create Authorization Proxy Server Certificates.
				  CreateCSR authproxy authproxy.csr authproxy.cfg authproxy.priv 6 $InstanceCertDir $s_certinfo
				  OnlineMint authproxy authproxy.csr authproxy.crt $s_certinfo.V6Template $InstanceCertDir $s_certinfo.IssuingCA

				  # Copy the Authorization Proxy Certs to the vCenter.
				  $filelocations = $null
				  $filelocations = @()
				  $filelocations += "$InstanceCertDir\authproxy\authproxy.priv"
				  $filelocations += "/var/lib/vmware/vmcam/ssl/authproxy.key"
				  $filelocations += "$InstanceCertDir\authproxy\authproxy.crt"
				  $filelocations += "/var/lib/vmware/vmcam/ssl/authproxy.crt"

				  CopyFiletoServer $filelocations $Deployment.hostname "root" $Deployment.VCSARootPass $esxihandle $true

				  # Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
				  $commandlist = $null
				  $commandlist = @()
				  $commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $commandlist += "export VMWARE_LOG_DIR=/var/log"
				  $commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
				  $commandlist += "export VMWARE_DATA_DIR=/storage"
				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
 				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				  $commandlist += "/usr/lib/vmware-vmcam/bin/camregister --unregister -a " + $Deployment.hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`'"
				  $commandlist += "/usr/bin/service-control --stop vmcam"
				  $commandlist += "mv /var/lib/vmware/vmcam/ssl/rui.crt /var/lib/vmware/vmcam/ssl/rui.crt.bak"
				  $commandlist += "mv /var/lib/vmware/vmcam/ssl/rui.key /var/lib/vmware/vmcam/ssl/rui.key.bak"
				  $commandlist += "mv /var/lib/vmware/vmcam/ssl/authproxy.crt /var/lib/vmware/vmcam/ssl/rui.crt"
				  $commandlist += "mv /var/lib/vmware/vmcam/ssl/authproxy.key /var/lib/vmware/vmcam/ssl/rui.key"
				  $commandlist += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.crt"
				  $commandlist += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.key"
				  $commandlist += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				  $commandlist += "/usr/lib/vmware-vmcam/bin/camregister --register -a " + $Deployment.hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`' -c /var/lib/vmware/vmcam/ssl/rui.crt -k /var/lib/vmware/vmcam/ssl/rui.key"

				  # Service update
				  ExecuteScript $commandlist $Deployment.hostname "root" $Deployment.VCSARootPass $esxihandle
			    }

        	  }

        Separatorline
        
        write-host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

        ConfigureCertPairs $Cert_Dir $Deployment $esxihandle

		# Write separator line to transcript.
		Separatorline
		
		write-host "=============== Restarting $($Deployment.vmName) ===============" | Out-String
		Restart-VMGuest -VM $Deployment.vmName -Server $esxihandle -Confirm:$false

		# Wait until the vcsa is available.
		Available $("https://" + $Deployment.Hostname)

		write-host "=============== End of Certificate Replacement for $($Deployment.vmName) ===============" | Out-String
	
		# Disconnect from the vcsa deployed esxi server.
		Disconnect-viserver -Server $esxihandle -Confirm:$false
	}

	Stop-Transcript
}

# Configure the vcsa.
ForEach ($Deployment in $s_Deployments | Where-Object {$_.Config}) {

	$OutputPath = "$LogPath\Config-" + $Deployment.Hostname + "-" + $(Get-date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting configuration of $($Deployment.vmName) ===============" | Out-String

	Separatorline

	# Wait until the vcsa is available.
	Available $("https://" + $Deployment.Hostname)
	
	# Create esxi credentials.
       $esxi_secpasswd		= $null
	$esxi_creds			= $null
	$esxi_secpasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$esxi_creds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $esxi_secpasswd)
	
	# Connect to esxi host of the deployed vcsa.
	$esxihandle = connect-viserver -server $Deployment.esxiHost -credential $esxi_creds

	Separatorline

	# Join the vcsa to the windows domain.
	JoinADDomain $Deployment $s_adinfo $esxihandle
	
	# if the vcsa is not a stand alone PSC, configure the vCenter.
	If ($Deployment.DeployType -ne "infrastructure" ) {

		Write-Output "== vCenter $($Deployment.vmName) configuration ==" | Out-String

		Separatorline

		$Datacenters	= $s_sites | Where-Object {$_.vcenter.split(",") -match "all|$($Deployment.Hostname)"}
		$sso_secpasswd	= ConvertTo-SecureString $($Deployment.SSOAdminPass) -AsPlainText -Force
		$sso_creds		= New-Object System.Management.Automation.PSCredential ($("Administrator@" + $Deployment.SSODomainName), $sso_secpasswd)

		# Connect to the vCenter
		$vchandle = Connect-viserver $Deployment.Hostname -Credential $sso_creds
		
		# Create Datacenter
		If ($Datacenters) {
			$Datacenters.Datacenter.ToUpper() | ForEach-Object {New-Datacenter -Location Datacenters -Name $_}
		}
			
		# Create Folders, Roles, and Permissions.
		$folders = $s_folders | Where-Object {$_.vcenter.split(",") -match "all|$($Deployment.Hostname)"}
		If ($folders) {
			Write-Output "Folders:" $folders
			CreateFolders $folders $vchandle
		}

		# if this is the first vCenter, create custom Roles.
		$existingroles = Get-VIRole -Server $vchandle
		$roles = $s_roles | Where-Object {$_.vcenter.split(",") -match "all|$($Deployment.Hostname)"} | Where-Object {$ExistingRoles -notcontains $_.Name}
           If ($roles) {
			Write-Output  "Roles:" $roles
			CreateRoles $roles $vchandle
		}	

		# Create OS Customizations for the vCenter.
		$s_Customizations | Where-Object {$_.Server -eq $Deployment.Hostname} | ForEach-Object {OSString $_}

		# Create Clusters
		ForEach ($Datacenter in $Datacenters) {
			# Define IP Octets
			$oct1 = $Datacenter.oct1
			$oct2 = $Datacenter.oct2
			$oct3 = $Datacenter.oct3
		
			# Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
               ($s_clusters | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)")`
                   -and ($_.Datacenter.split(",") -match "all|$($Datacenter.Datacenter)")}).Clustername |`
				ForEach-Object {If ($_) {New-Cluster -Location (Get-Datacenter -Server $vchandle -Name $Datacenter.Datacenter) -Name $_}}
					
			# Create New vDSwitch
			# Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
			$vdswitches = $s_vdswitches | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}

			ForEach ($vdswitch in $vdswitches) {		
				$SwitchDatacenter	= Get-Inventory -Name $Datacenter.Datacenter

				If ($vdswitch.SwitchNumber.ToString().indexof(".") -eq -1) {
					$SwitchNumber = $vdswitch.SwitchNumber.ToString() + ".0"}
				Else { $SwitchNumber = $vdswitch.SwitchNumber.ToString()}
			
				$SwitchName = $SwitchNumber + " " + $vdswitch.vDSwitchName -replace "XXX", $Datacenter.Datacenter
			
				# Create new vdswitch.
				New-VDSwitch -Server $vchandle -Name $SwitchName -Location $SwitchDatacenter -Mtu $mtu -NumUplinkPorts 2 -Version $vdswitch.Version
				
				# Enable NIOC
				(get-vdswitch -Server $vchandle -Name $SwitchName | get-view).EnableNetworkResourceManagement($true)

				$vlanadd = $s_vlans | Where-Object {$_.Number.StartsWith($SwitchName.split(" ")[0])}
				$vlanadd = $vlanadd | Where-Object {$_.Datacenter.split(",") -match "all|$($Datacenter.Datacenter)"}
				$vlanadd = $vlanadd | Where-Object {$_.vCenter.split(",") -match "all|$($Deployment.Hostname)"}
				
				# Create Portgroups
				ForEach ($vlan in $vlanadd) {
				
					$PortGroup =	$vlan.Number.padright(8," ") +`
									$vlan.Vlan.padright(8," ") + "- " +`
									$vlan.Network.padright(19," ") + "- " +`
									$vlan.VlanName

					$PortGroup = $PortGroup -replace "oct1", $oct1
					$PortGroup = $PortGroup -replace "oct2", $oct2
					$PortGroup = $PortGroup -replace "oct2", $oct3
					
                       If ($PortGroup.split("-")[0] -like "*trunk*") {
                           New-VDPortgroup -Server $vchandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.split("-")[0] -VlanTrunkRange $vlan.network
                       }
                       Else {
					    New-VDPortgroup -Server $vchandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.split("-")[0] -VlanId $vlan.vlan.split(" ")[1]
                       }
					# Set Portgroup Team policies
					If ($PortGroup -like "*vmotion-1*") {
						Get-vdportgroup -Server $vchandle | Where-Object {$_.Name.split('%')[0] -like $PortGroup.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vchandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
					}
					If ($PortGroup -like "*vmotion-2*") {
						Get-vdportgroup -Server $vchandle | Where-Object {$_.Name.split('%')[0] -like $PortGroup.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vchandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
					}
					If ($PortGroup -notlike "*vmotion*") {
						Get-vdportgroup -Server $vchandle | Where-Object {$_.Name.split('%')[0] -like $PortGroup.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vchandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
					}
					Else
					{
					#Set Traffic Shaping on vmotion portgroups for egress traffic
					Get-VDPortgroup -Server $vchandle -VDSwitch $SwitchName | Where-Object {$_.Name.split('%')[0] -like $PortGroup.split('/')[0]} | Get-VDTrafficShapingPolicy -Server $vchandle -Direction Out| Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
					}
				}
			}
		}

		# Add Licenses to vCenter.
		If ($s_Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) { ConfigureLicensing $($s_Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $vchandle}

		# Select permissions for all vCenters or the current vCenter.
		# Create the permissions.
		CreatePermissions $($s_Permissions | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}) $vchandle
		
		$InstanceCertDir = $Cert_Dir + "\" + $Deployment.Hostname
		
		# Configure Additional Services (Network Dump, Autodeploy, TFTP)
		ForEach ($serv in $s_Services) {
			Write-Output $serv | Out-String
			If ($serv.vCenter.split(",") -match "all|$($Deployment.Hostname)") {
				Switch ($serv.Service) {
					AuthProxy	{ ConfigureAuthProxy $Deployment $esxihandle $s_adinfo; Break}
					AutoDeploy	{ $vchandle | get-advancedsetting -Name vpxd.certmgmt.certs.minutesBefore | Set-AdvancedSetting -Value 1 -Confirm:$false
								  ConfigureAutoDeploy $Deployment $esxihandle $vchandle.version
								  If ($s_arules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) { ConfigureAutoDeployRules $($s_arules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $FolderPath $vchandle}
								  ; Break
					}
					Netdumpster	{ ConfigureNetdumpster $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle $vchandle.version; Break}
					TFTP		{ ConfigureTFTP $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle; Break}
					default {Break}
				}
			}
		}

           # Configure plugins
           $commandlist = $null
           $commandlist = @()
           $Plugins = $s_Plugins | Where-Object {$_.config -and $_.vCenter.split(",") -match "all|$($Deployment.Hostname)"}

		Separatorline
		Write-Output $Plugins | Out-String
		Separatorline
		
           For ($i=0;$i -lt $Plugins.Count;$i++){
               If ($Plugins[$i].SourceDir) {
                   If ($commandlist) {
                       ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle
                       $commandlist = $null
                       $commandlist = @()
                   }

                   $filelocations = $null
                   $filelocations = @()
	               $filelocations += "$($FolderPath)\$($Plugins[$i].SourceDir)\$($Plugins[$i].SourceFiles)"
                   $filelocations += $Plugins[$i].DestDir

				Write-Output $filelocations | Out-String

       	        CopyFiletoServer $filelocations $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle $true
               }

               If ($Plugins[$i].Command) {$commandlist += $Plugins[$i].Command}
           }

           If ($commandlist) {ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle}

		Separatorline

		# Disconnect from the vCenter.
		Disconnect-viserver -server $vchandle -Confirm:$false

		Separatorline

	}

	# Run the vami_set_hostname to set the correct FQDN in the /etc/hosts file on a vCenter with External PSC only.
	If ($Deployment.DeployType -like "*management*") {
		$commandlist = $null
		$commandlist = @()
		$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$commandlist += "export VMWARE_LOG_DIR=/var/log"
		$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
		$commandlist += "export VMWARE_DATA_DIR=/storage"
		$commandlist += "/opt/vmware/share/vami/vami_set_hostname $($Deployment.Hostname)"
		
		ExecuteScript $commandlist $Deployment.Hostname "root" $Deployment.VCSARootPass $esxihandle
       }

	# Disconnect from the vcsa deployed esxi server.
	Disconnect-viserver -Server $esxihandle -Confirm:$false

	Separatorline

	write-host "=============== End of Configuration for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

Separatorline

Write-Output "<=============== Deployment Complete ===============>" | Out-String

# Scrub logfiles
$logfiles = (Get-ChildItem -Path $LogPath).FullName

If ($s_summary.TranscriptScrub) {
    ForEach ($log in $logfiles) {
        $Transcript = Get-Content -path $log
	    ForEach ($pass in $scrub) {
		    $Transcript = $Transcript.replace($Pass,'<-- Password Redacted -->')}
    	$Transcript | Set-Content -path $log -force -confirm:$false
    }
}
