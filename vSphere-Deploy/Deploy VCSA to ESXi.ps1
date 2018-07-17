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
22. CheckOpenSSL				  Y
23. CreatePEMFiles				  Y
24. CreateCSR					  Y
25. CreateSolutionCSR			  Y
26. CreateVMCACSR				  Y
27. DisplayVMDir				  Y
28. DownloadRoots				  Y		Use-Openssl
29. MoveUserCerts				  Y
30. OnlineMint					  Y
31. OnlineMintResume			  N
32.	SaveToYaml					  Y
33. SaveToJson					  Y
34.	Use-Openssl					  Y
35.	Set-VMHostProfileExtended	  Y
36. TransferCertToNode			  Y		ExecuteScript, CopyFiletoServer
37. UserPEMFiles				  Y		CreatePEMFiles
38.	VMDirRename					  Y
39. VMCAMint					  N
40. CDDir						  Y
41. CreateVCSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles
42. CreatePscSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles

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
    $ExcelFileName  = $FilePath.Split("\")[$FilePath.Split("\").count -1]
    $FolderPath     = $FilePath.Substring(0,$FilePath.Lastindexof("\"))
}

function Available {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
		$URL
	)

	# Test url for TCP Port 80 Listening.
	While (!(Test-NetConnection -ComputerName $($URL.Split("//")[2]) -Port 80).TCPTestSucceeded) {
		Write-Host "`r`n $URL not ready, sleeping for 30 sec.`r`n" -foregroundcolor cyan
		Start-Sleep -s 30
	}

	# https://stackoverflow.com/questions/46036777/unable-to-connect-to-help-content-the-server-on-which-help-content-is-stored-mi
	[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, Ssl3"

	# Make sure that the url is available.
	Do { $Failed = $false

		Try { (Invoke-WebRequest -uri $URL -UseBasicParsing -TimeoutSec 20 -ErrorAction Ignore).StatusCode -ne 200 }
		Catch { $Failed = $true
				Write-Host "`r`n $URL not ready, sleeping for 30 sec.`r`n" -foregroundcolor cyan
				Start-Sleep -s 30
		}

	} While ($Failed)
}

# Configure the Autodeploy Service - set auto start, register vCenter, and start service.
function ConfigureAutoDeploy {
	Param (
        [Parameter(Mandatory=$true, Position=0)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle
	)

	$CommandList = $null
	$CommandList = @()

    # Register Autodeploy to vCenter if not changing certificates.
	If (!$Deployment.Certs) {
		$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$CommandList += "export VMWARE_LOG_DIR=/var/log"
		$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
		$CommandList += "export VMWARE_DATA_DIR=/storage"
		$CommandList += "/usr/lib/vmware-vmon/vmon-cli --stop rbd"
		$CommandList += "/usr/bin/autodeploy-register -R -a " + $Deployment.IP + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -p 80"

		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle}

	# Set Autodeploy (rbd) startype to Automatic and restart service.
	$CommandList = $null
	$CommandList = @()
	$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$CommandList += "export VMWARE_LOG_DIR=/var/log"
	$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
	$CommandList += "export VMWARE_DATA_DIR=/storage"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"

	# imagebuilder set startype to Automatic and restart service.
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"

	# Service update
	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
}

function ConfigureAuthProxy {
	Param (
        [Parameter(Mandatory=$true, Position=0)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle,
		[Parameter(Mandatory=$true, Position=2)]
		$ADDomain
	)

	# Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
	$CommandList = $null
	$CommandList = @()
	$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$CommandList += "export VMWARE_LOG_DIR=/var/log"
	$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
	$CommandList += "export VMWARE_DATA_DIR=/storage"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
 	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
 	$CommandList += "/usr/lib/vmware-vmcam/bin/camconfig add-domain -d " + $ADDomain.ADDomain + " -u " + $ADDomain.ADVMCamUser + " -w `'" + $ADDomain.ADvmcamPass + "`'"

	# Service update
	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
}

function ConfigureAutoDeployRules {
	Param (
        [Parameter(Mandatory=$true, Position=0)]
		$Rules,
		[Parameter(Mandatory=$true, Position=1)]
		$Path,
		[Parameter(Mandatory=$true, Position=2)]
		$VIHandle
	)

	Write-Output $Rules | Out-String

	# Turn off signature check - needed to avoid errors from unsigned packages/profiles.
	#$DeployNoSignatureCheck = $true

	ForEach ($Rule in $Rules) {
		$HostProfExport = $Path + "\" + $Rule.ProfileImport

		$SI = Get-View -Server $VIHandle ServiceInstance
		$HostProfMgr = Get-View -Server $VIHandle -Id $SI.Content.HostProfileManager

		$Spec 					  = New-Object VMware.Vim.HostProfileSerializedHostProfileSpec
		$Spec.Name 				  = $Rule.ProfileName
		$Spec.Enabled 			  = $true
		$Spec.Annotation		  = $Rule.ProfileAnnotation
		$Spec.Validating		  = $false
		$Spec.ProfileConfigString = (Get-Content -Path $HostProfExport)

		$HostProfMgr.CreateProfile($Spec)

		Write-Output $HostProfMgr | Out-String

		# Add offline bundles to depot
		$Depotpath = $Path + "\" + $Rule.SoftwareDepot
		Add-EsxSoftwareDepot $Depotpath

		# Create a new deploy rule.
		$Img = Get-EsxImageProfile | Where-Object {$Rule.SoftwareDepot.Substring(0,$Rule.SoftwareDepot.Indexof(".zip"))}
		if ($Img.count -gt 1) {$Img = $Img[1]}
		Write-Output $Img | Out-String

		$Pro = Get-VMHostProfile -Server $VIHandle | Where-Object {$_.Name -eq $Rule.ProfileName}
		Write-Output $Pro | Out-String

		$Clu = Get-Datacenter -Server $VIHandle -Name $Rule.Datacenter | Get-Cluster -Name $Rule.Cluster
		Write-Output $Clu | Out-String

		Write-Output "New-DeployRule -Name $($Rule.RuleName) -Item $Img, $Pro, $Clu -Pattern $($Rule.Pattern)" | Out-String
		New-DeployRule -Name $Rule.RuleName -Item $Img, $Pro, $Clu -Pattern $Rule.Pattern -ErrorAction SilentlyContinue

		# Activate the deploy rule.
		Add-DeployRule -DeployRule $Rule.RuleName -ErrorAction SilentlyContinue
	}

}

# Configure Private/Public Keys for ssh authentication without password.
function ConfigureCertPairs {
	Param (
        [Parameter(Mandatory=$true, Position=0)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=1)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=2)]
		$VIHandle
	)

	$CertPath	= $CertDir + "\" + $Deployment.Hostname

	$Script = '[ ! -s /root/.ssh/authorized_keys ] && echo "File authorized keys does not exist or is empty."'
	$CreateKeyPair = $(ExecuteScript $Script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput

	If ($CreateKeyPair) {
    	# Create key pair for logining in to host without password.
		$CommandList = $null
		$CommandList = @()
		# Create and pemissions .ssh folder.
		$CommandList += "mkdir /root/.ssh"
    	$CommandList += "chmod 700 /root/.ssh"
    	# Create key pair for logining in to host without password.
    	$CommandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.Hostname + " -q"
    	# Add public key to authorized_keys for root account and permission authorized_keys.
    	$CommandList += "cat /root/.ssh/" + $Deployment.Hostname + ".pub >> /root/.ssh/authorized_keys"
		$CommandList += "chmod 600 /root/.ssh/authorized_keys"

		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

    	# Copy private and public keys to deployment folder for host.
		$FileLocations = $null
		$FileLocations = @()
		$FileLocations += "/root/.ssh/" + $Deployment.Hostname
		$FileLocations += $CertPath+ "\" + $Deployment.Hostname + ".priv"
		$FileLocations += "/root/.ssh/" + $Deployment.Hostname + ".pub"
		$FileLocations += $CertPath+ "\" + $Deployment.Hostname + ".pub"

    	CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false

		# If there is no global private/public keys pair for the SSO domain hosts, create it.
    	If (!(Test-Path $($CertDir + "\" + $Deployment.SSODomainName + ".priv"))) {
        	$CommandList = $null
        	$CommandList = @()
        	# Create key pair for logining in to host without password.
        	$CommandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.SSODomainName + " -q"
        	# Add public key to authorized_keys for root account and permission authorized_keys.
        	$CommandList += "cat /root/.ssh/" + $Deployment.SSODomainName + ".pub >> /root/.ssh/authorized_keys"

        	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

        	$FileLocations = $null
        	$FileLocations = @()
        	$FileLocations += "/root/.ssh/" + $Deployment.SSODomainName
    		$FileLocations += $CertDir + "\" + $Deployment.SSODomainName + ".priv"
        	$FileLocations += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
        	$FileLocations += $CertDir + "\" + $Deployment.SSODomainName + ".pub"

        	CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false
    	}
    	Else {
				$FileLocations = $null
				$FileLocations = @()
	        	$FileLocations += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
	        	$FileLocations += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"

	        	CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $true

	        	$CommandList = $null
	        	$CommandList = @()
	        	# Add public cert to authorized keys.
        		$CommandList += "cat /root/.ssh/$($Deployment.SSODomainName).pub >> /root/.ssh/authorized_keys"

        		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
		}
	}
}

# Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.
function ConfigureIdentity67 {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=1)]
		$ADInfo
	)

	# Add AD domain as Native Identity Source.
	Write-Output "============ Adding AD Domain as Identity Source for SSO on vCenter Instance 6.7 ============" | Out-String

	Available $("https://" + $Deployment.Hostname + "/ui/")

	Start-Sleep -Seconds 10

	# Get list of existing Internet Explorer instances.
	$Instances = Get-Process -Name iexplore -erroraction silentlycontinue

	$IE = New-Object -com InternetExplorer.Application

	$IE.Visible = $false

	$URI = "https://" + $Deployment.Hostname + "/ui/"

	Do {
		$IE.Navigate($URI)

		while($IE.ReadyState -ne 4) {Start-Sleep -m 100}

		while($IE.Document.ReadyState -ne "complete") {Start-Sleep -m 100}

		Write-Output $IE.Document.url | Out-String

		Start-Sleep -Seconds 30

	} Until ($IE.Document.url -match "websso")

	Write-Output "ie" | Out-String
	Write-Output $IE | Out-String

	Separatorline

	Start-Sleep 1

	$IE.Document.DocumentElement.GetElementsByClassName("margeTextInput")[0].value = 'administrator@' + $Deployment.SSODomainName
	$IE.Document.DocumentElement.GetElementsByClassName("margeTextInput")[1].value = $Deployment.SSOAdminPass

	Start-Sleep 1

	# Enable the submit button and click it.
	$IE.Document.DocumentElement.GetElementsByClassName("button blue")[0].Disabled = $false
	$IE.Document.DocumentElement.GetElementsByClassName("button blue")[0].click()

	Start-Sleep 10

	$URI = "https://" + $Deployment.Hostname + "/ui/#?extensionId=vsphere.core.administration.configurationView"

	$IE.Navigate($URI)

	Start-Sleep 1

	($IE.Document.DocumentElement.getElementsByClassName('btn btn-link nav-link nav-item') | Where-Object {$_.id -eq 'clr-tab-link-3'}).click()

	Start-Sleep 1

	($IE.Document.DocumentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'addNewIdentity'}).click()

	Start-Sleep 1

	$IE.Document.DocumentElement.getElementsByClassName('btn btn-primary')[0].click()

	Start-Sleep 1

	$Selections = ($IE.Document.DocumentElement.getElementsByTagName("clr-dg-cell") | Select-Object outertext).outertext -replace " ",""
	$Row =  0..2 | Where-Object {$Selections[1,7,13][$_] -eq $ADInfo.ADDomain}

	$IE.Document.DocumentElement.getElementsByClassName("radio")[$Row].childnodes[3].click()

	($IE.Document.DocumentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'defaultIdentity'}).click()

	Start-Sleep 1

	$IE.Document.DocumentElement.getElementsByClassName('btn btn-primary')[0].click()

	# Exit Internet Explorer.
	$IE.quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($IE)

	$IE = $null

	# Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
	$NewInstances = Get-Process -Name iexplore
	$NewInstances | Where-Object {$Instances.id -notcontains $_.id} | stop-process

	Write-Output "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String
}


# Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.
function ConfigureIdentity65 {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Deployment
	)

	# Add AD domain as Native Identity Source.
	Write-Output "============ Adding AD Domain as Identity Source for SSO on PSC Instance 6.5 ============" | Out-String

	Start-Sleep -Seconds 10

    # Get list of existing Internet Explorer instances.
	$Instances = Get-Process -Name iexplore -erroraction silentlycontinue

	# Create new Internet Explorer instance.
	$IE = New-Object -com InternetExplorer.Application

	# Don't make the Internet Explorer instance visible.
	$IE.Visible = $false

	# Navigate to https://<fqdn of host>/psc/
	$IE.Navigate($("https://" + $Deployment.Hostname + "/psc/"))

	# Wait while page finishes loading.
	while($IE.ReadyState -ne 4) {Start-Sleep -m 100}
	while($IE.Document.ReadyState -ne "complete") {Start-Sleep -m 100}

	Separatorline

	Write-Output "ie" | Out-String
	Write-Output $IE | Out-String

	Separatorline

    # Fill in the username and password fields with the SSO Administrator credentials.
	$IE.Document.DocumentElement.getElementsByClassName('margeTextInput')[0].value = 'administrator@' + $Deployment.SSODomainName
	$IE.Document.DocumentElement.getElementsByClassName('margeTextInput')[1].value = $Deployment.SSOAdminPass

    # Enable the submit button and click it.
	$IE.Document.DocumentElement.getElementsByClassName('button blue')[0].Disabled = $false
	$IE.Document.DocumentElement.getElementsByClassName('button blue')[0].click()

	Start-Sleep 10

    # Navigate to the add Identity Sources page for the SSO.
	$IE.Navigate("https://" + $Deployment.Hostname + "/psc/#?extensionId=sso.identity.sources.extension")

	Write-Output $IE | Out-String

	Start-Sleep 1

	# Select the Add Identity Source button and click it.
	$CA = $IE.Document.DocumentElement.getElementsByClassName('vui-action-label ng-binding ng-scope') | Select-Object -first 1
	$CA.click()

	Start-Sleep 1

    # Click the Active Directory Type Radio button.
	$IE.Document.DocumentElement.getElementsByClassName('ng-pristine ng-untouched ng-valid')[0].click()

	Start-Sleep 1

    # Click OK.
	$CA = $IE.Document.DocumentElement.getElementsByClassName('ng-binding') | Where-Object {$_.innerHTML -eq "OK"}
	$CA.click()

    # Exit Internet Explorer.
	$IE.quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($IE)

	$CA = $null
	$IE = $null

	# Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
	$NewInstances = Get-Process -Name iexplore -ErrorAction SilentlyContinue
	$NewInstances | Where-Object {$Instances.id -notcontains $_.id} | stop-process

	Write-Output "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String

}

function ConfigureSSOGroups {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=1)]
		$ADInfo,
		[Parameter(Mandatory=$true, Position=2)]
		$VIHandle
	)

	Write-Output "============ Add AD Groups to SSO Admin Groups ============" | Out-String

	$SubDomain		= $Deployment.SSODomainName.Split(".")[0]
	$DomainExt		= $Deployment.SSODomainName.Split(".")[1]

	# Active Directory variables
	$ADAdminsGroupSID	= (Get-ADgroup -Identity $ADInfo.ADvCenterAdmins).sid.value

	$VersionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$Script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $Script | Out-String

	$VIVersion = $(ExecuteScript $Script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("") | Select-String -pattern $VersionRegex

	Write-Output $VIVersion

	If ($Deployment.Parent) {$LDAPServer = $Deployment.Parent}
		Else {$LDAPServer = $Deployment.Hostname}

	$CommandList = $null
	$CommandList = @()

	# Set Default SSO Identity Source Domain
	If ($VIVersion -match "6.5.") {
		$CommandList += "echo -e `"dn: cn=$($Deployment.SSODomainName),cn=Tenants,cn=IdentityManager,cn=Services,dc=$SubDomain,dc=$DomainExt`" >> defaultdomain.ldif"
		$CommandList += "echo -e `"changetype: modify`" >> defaultdomain.ldif"
		$CommandList += "echo -e `"replace: vmwSTSDefaultIdentityProvider`" >> defaultdomain.ldif"
		$CommandList += "echo -e `"vmwSTSDefaultIdentityProvider: $($ADInfo.ADDomain)`" >> defaultdomain.ldif"
		$CommandList += "echo -e `"-`" >> defaultdomain.ldif"
		$CommandList += "/opt/likewise/bin/ldapmodify -f /root/defaultdomain.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'$($Deployment.VCSARootPass)`'"
	}

	# Add AD vCenter Admins to Component Administrators SSO Group.
	$CommandList += "echo -e `"dn: cn=ComponentManager.Administrators,dc=$SubDomain,dc=$DomainExt`" >> groupadd_cma.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_cma.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_cma.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_cma.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_cma.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_cma.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"

	# Add AD vCenter Admins to License Administrators SSO Group.
	$CommandList += "echo -e `"dn: cn=LicenseService.Administrators,dc=$SubDomain,dc=$DomainExt`" >> groupadd_la.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_la.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_la.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_la.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_la.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_la.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"

	# Add AD vCenter Admins to Administrators SSO Group.
	$CommandList += "echo -e `"dn: cn=Administrators,cn=Builtin,dc=$SubDomain,dc=$DomainExt`" >> groupadd_adm.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_adm.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_adm.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_adm.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_adm.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_adm.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"

	# Add AD vCenter Admins to Certificate Authority Administrators SSO Group.
	$CommandList += "echo -e `"dn: cn=CAAdmins,cn=Builtin,dc=$SubDomain,dc=$DomainExt`" >> groupadd_caa.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_caa.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_caa.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_caa.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_caa.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_caa.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"

	# Add AD vCenter Admins to Users SSO Group.
	$CommandList += "echo -e `"dn: cn=Users,cn=Builtin,dc=$SubDomain,dc=$DomainExt`" >> groupadd_usr.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_usr.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_usr.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_usr.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_usr.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_usr.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"

	# Add AD vCenter Admins to System Configuration Administrators SSO Group.
	$CommandList += "echo -e `"dn: cn=SystemConfiguration.Administrators,dc=$SubDomain,dc=$DomainExt`" >> groupadd_sca.ldif"
	$CommandList += "echo -e `"changetype: modify`" >> groupadd_sca.ldif"
	$CommandList += "echo -e `"add: member`" >> groupadd_sca.ldif"
	$CommandList += "echo -e `"member: externalObjectId=$ADAdminsGroupSID`" >> groupadd_sca.ldif"
	$CommandList += "echo -e `"-`" >> groupadd_sca.ldif"
	$CommandList += "/opt/likewise/bin/ldapmodify -f /root/groupadd_sca.ldif -h $LDAPServer -D `"cn=Administrator,cn=Users,dc=$SubDomain,dc=$DomainExt`" -w `'" + $Deployment.VCSARootPass + "`'"
	$CommandList += 'rm /root/*.ldif'

	# Excute the commands in $CommandList on the vcsa.
	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
}

# http://vniklas.djungeln.se/2012/03/29/a-powercli-function-to-manage-vmware-vsphere-licenses/
function ConfigureLicensing {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Licenses,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle
	)

	Write-Output $Licenses | Out-String
	$ValidLicenses = $Licenses | where-Object {($_.psobject.properties.value | Measure-Object).Count -eq 4}
	ForEach ($License in $ValidLicenses) {
		$LicMgr		= $null
		$AddLic		= $null
		$LicType	= $null
		# Add License Key
		$LicMgr  = Get-View -Server $VIHandle ServiceInstance
		$AddLic  = Get-View -Server $VIHandle $LicMgr.Content.LicenseManager
		Write-Output "Current Licenses in vCenter $($AddLic.Licenses.LicenseKey)" | Out-String
		If (!($AddLic.Licenses.LicenseKey | Where-Object {$_ -eq $License.LicKey.trim()})) {
			Write-Output "Adding $($License.LicKey) to vCenter" | Out-String
			$LicType = $AddLic.AddLicense($($License.LicKey.trim()),$null)
		}

		If ($LicType.Name -like "*vcenter*") {
			# Assign vCenter License
			$VCUUID 		= $LicMgr.Content.About.InstanceUuid
			$VCDisplayName	= $LicMgr.Content.About.Name
			$LicAssignMgr	= Get-View -Server $VIHandle $AddLic.licenseAssignmentManager
			If ($LicAssignMgr) {
				$LicAssignMgr.UpdateAssignedLicense($VCUUID, $License.LicKey, $VCDisplayName)
			}
		}
		Else {
			  # Assign Esxi License
			  $LicDataMgr = Get-LicenseDataManager -Server $VIHandle
			  For ($i=0;$i -lt $License.ApplyType.Split(",").count;$i++) {
				   Switch ($License.ApplyType.Split(",")[$i]) {
					 CL {$VIContainer = Get-Cluster -Server $VIHandle -Name $License.ApplyTo.Split(",")[$i]; Break}
					 DC {If($License.ApplyTo.Split(",")[$i] -eq "Datacenters") {
						 	$VIContainer = Get-Folder -Server $VIHandle -Name $License.ApplyTo.Split(",")[$i] -Type "Datacenter"
					 	 } Else {$VIContainer = Get-Datacenter -Server $VIHandle -Name $License.ApplyTo.Split(",")[$i]}; Break}
					 FO {$VIContainer = Get-Folder -Server $VIHandle -Name $License.ApplyTo.Split(",")[$i] -Type "HostAndCluster"; Break}
					 default {$VIContainer = $null; Break}
				   }

				   Write-Output $VIContainer | Out-String

				   If ($VIContainer) {
				   	   $LicData					= New-Object VMware.VimAutomation.License.Types.LicenseData
				   	   $LicKeyEntry				= New-Object Vmware.VimAutomation.License.Types.LicenseKeyEntry
				       $LicKeyEntry.TypeId 		= "vmware-vsphere"
				       $LicKeyEntry.LicenseKey	= $License.LicKey
				       $LicData.LicenseKeys 	+= $LicKeyEntry
				       $LicDataMgr.UpdateAssociatedLicenseData($VIContainer.Uid, $LicData)
				       $LicDataMgr.QueryAssociatedLicenseData($VIContainer.Uid)
				   }
			  }
		}
	}
}

# Configure Network Dumpster to Auto Start and start service.
function ConfigureNetdumpster {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Hostname,
		[Parameter(Mandatory=$true, Position=1)]
		$Username,
		[Parameter(Mandatory=$true, Position=2)]
		$Password,
		[Parameter(Mandatory=$true, Position=3)]
		$VIHandle
	)

	$CommandList = $null
	$CommandList = @()

	$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$CommandList += "export VMWARE_LOG_DIR=/var/log"
	$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
	$CommandList += "export VMWARE_DATA_DIR=/storage"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --update netdumper --starttype AUTOMATIC"
	$CommandList += "/usr/lib/vmware-vmon/vmon-cli --start netdumper"

	# Service update
	ExecuteScript $CommandList $Hostname $Username $Password $VIHandle
}

# Configure TFTP, set firewall exemption, set service to auto start, start service.
function ConfigureTFTP {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Hostname,
		[Parameter(Mandatory=$true, Position=1)]
		$Username,
		[Parameter(Mandatory=$true, Position=2)]
		$Password,
		[Parameter(Mandatory=$true, Position=3)]
		$VIHandle
	)

	$CommandList = $null
	$CommandList = @()

	# Set Permanent Firewall Exception
	$CommandList += 'echo -e "{" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "  	\"firewall\": {" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "    	\"enable\": true," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "    	\"rules\": [" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "      	{" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"protocol\": \"tcp\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "      	}," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "      {" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"protocol\": \"udp\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "        	\"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "      }" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "    ]" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "  }" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += 'echo -e "}" >> /etc/vmware/appliance/firewall/tftp'
	$CommandList += "echo `"#!/bin/bash`" > /tmp/tftpcmd"
	$CommandList += "echo -n `"sed -i `" >> /tmp/tftpcmd"
	$CommandList += "echo -n `'`"s/`' >> /tmp/tftpcmd"
	$CommandList += "echo -n \`'/ >> /tmp/tftpcmd"
	$CommandList += "echo -n `'\`' >> /tmp/tftpcmd"
	$CommandList += "echo -n `'`"/g`' >> /tmp/tftpcmd"
	$CommandList += "echo -n `'`"`' >> /tmp/tftpcmd"
	$CommandList += "echo -n `" /etc/vmware/appliance/firewall/tftp`" >> /tmp/tftpcmd"
	$CommandList += "chmod a+x /tmp/tftpcmd"
	$CommandList += "/tmp/tftpcmd"
	$CommandList += "rm /tmp/tftpcmd"

	$CommandList += "more /etc/vmware/appliance/firewall/tftp"
	# Enable TFTP service.
	$CommandList += "/sbin/chkconfig atftpd on"
	# Start TFTP service.
	$CommandList += "/etc/init.d/atftpd start"
	$CommandList += "/usr/lib/applmgmt/networking/bin/firewall-reload"
	# Set Firewall Exception until reboot.
	$CommandList += "iptables -A port_filter -p udp -m udp --dport 69 -j ACCEPT"

	# Service update
	ExecuteScript $CommandList $Hostname $Username $Password $VIHandle
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

	$MyStack = new-object system.collections.stack

	$Headers = $InputObject[0].PSObject.Properties.Name
	$Values  = $InputObject | ForEach-Object {$_.psobject.properties.Value}

	If ($Headers.count -gt 1) {
		$Values[($Values.length - 1)..0] | ForEach-Object {$MyStack.Push($_)}
		$Headers[($Headers.length - 1)..0] | ForEach-Object {$MyStack.Push($_)}
	}
	Else {
		$Values	 | ForEach-Object {$MyStack.Push($_)}
		$Headers | ForEach-Object {$MyStack.Push($_)}
	}

	$Columns = $Headers.count
	$Rows = $Values.count/$Headers.count + 1
	$Array = New-Object 'object[,]' $Rows, $Columns

	For ($i=0;$i -lt $Rows;$i++)
		{
			For ($j = 0; $j -lt $Columns; $j++) {
				$Array[$i,$j] = $MyStack.Pop()
			}
		}

	$WorkSheet.name = $SheetName
	If ($Columns -le 26) {
		$ASCII = [char]($Columns + 96) + $Rows
	}
	Else { $ASCII = "aa" + $Rows}
	$range = $WorkSheet.Range("a1",$ASCII)
	$range.Value2 = $Array
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
            $Collection = @(
                foreach ($Object in $InputObject) { ConvertPSObjectToHashtable $Object }
            )

            Write-Output -NoEnumerate $Collection
        }
        Elseif ($InputObject -is [psobject])
        {
            $Hash = @{}

            foreach ($Property in $InputObject.PSObject.Properties)
            {
                $Hash[$Property.Name] = ConvertPSObjectToHashtable $Property.Value
            }

            $Hash
        }
        Else
        {
            $InputObject
        }
    }
}

# Deploy a VCSA.
function Deploy {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$ParameterList,
		[Parameter(Mandatory=$true, Position=1)]
		$OvfToolPath,
		[Parameter(Mandatory=$true, Position=2)]
		$LogPath
	)

	$PSCS			= @("tiny","small","medium","large","infrastructure")

	$ArgumentList	= @()
	$OvfTool		= $OvfToolPath + "\ovftool.exe"

	# Get Esxi Host Certificate Thumbrpint.
	$URL = "https://" + $ParameterList.esxiHost
	$WebRequest = [Net.WebRequest]::Create($URL)
	Try { $WebRequest.GetResponse() } Catch {}
	$ESXiCert = $WebRequest.ServicePoint.Certificate
	$ESXiThumbPrint = $ESXiCert.GetCertHashString() -replace '(..(?!$))','$1:'

	If ($parameterlist.Action -ne "--version") {
		$ArgumentList += "--X:logFile=$LogPath\ofvtool_" + $ParameterList.vmName + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
		$ArgumentList += "--X:logLevel=verbose"
		$ArgumentList += "--acceptAllEulas"
		$ArgumentList += "--skipManifestCheck"
		$ArgumentList += "--targetSSLThumbprint=$ESXiThumbPrint"
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
		If ($parameterlist.Action -eq "first" -and $PSCS -contains $ParameterList.DeployType) {
			$ArgumentList += "--prop:guestinfo.cis.vmdir.first-instance=True"
		}
		Else {
			  $ArgumentList += "--prop:guestinfo.cis.vmdir.first-instance=False"
			  $ArgumentList += "--prop:guestinfo.cis.vmdir.replication-partner-Hostname=" + $ParameterList.Parent
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
function CreateFolders {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Folders,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle
	)

Separatorline

	ForEach ($Folder in $Folders) {
		Write-Output $Folder.Name | Out-String
		ForEach ($Datacenter in get-datacenter -Server $VIHandle) {
			If ($Folder.datacenter.Split(",") -match "all|$($Datacenter.name)") {
				$Location = $Datacenter | get-folder -name $Folder.Location | Where-Object {$_.Parentid -notlike "*ha*"}
				Write-Output $Location | Out-String
				New-Folder -Server $VIHandle -Name $Folder.Name -Location $Location -Confirm:$false
			}
		}
	}

	Separatorline
}

# Create Roles
function CreateRoles {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Roles,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle
	)

	Separatorline

	$ExistingRoles = Get-ViRole -Server $VIHandle | Select-Object Name

	$Names = $($Roles | Select-Object Name -Unique) | Where-Object {$ExistingRoles.name -notcontains $_.name}

	Write-Output $Names | Out-String

	ForEach ($Name in $Names) {
		$VPrivilege = $Roles | Where-Object {$_.Name -like $Name.Name} | Select-Object Privilege

		Write-Output $VPrivilege | Out-String

		New-VIRole -Server $VIHandle -Name $Name.Name -Privilege (Get-VIPrivilege -Server $VIHandle | Where-Object {$VPrivilege.Privilege -like $_.id})
	}

	Separatorline
}

# Set Permissions
function CreatePermissions {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$VPermissions,
		[Parameter(Mandatory=$true, Position=1)]
		$VIHandle
	)

	Separatorline

	Write-Output  "Permissions:" $VPermissions  | Out-String

	ForEach ($Permission in $VPermissions) {
		$Entity = Get-Inventory -Name $Permission.Entity | Where-Object {$_.Id -match $Permission.Location}
		If ($Permission.Group) {
			$Principal = Get-VIAccount -Group -Name $Permission.Principal -Server $VIHandle
		}
		Else {
			$Principal = Get-VIAccount -Name $Permission.Principal -Server $VIHandle
		}

		Write-Output "New-VIPermission -Server $VIHandle -Entity $Entity -Principal $Principal -Role $($Permission.Role) -Propagate $([System.Convert]::ToBoolean($Permission.Propagate))" | Out-String

		New-VIPermission -Server $VIHandle -Entity $Entity -Principal $Principal -Role $Permission.Role -Propagate $([System.Convert]::ToBoolean($Permission.Propagate))

	}

	Separatorline
}

# Execute a script via Invoke-VMScript.
function ExecuteScript {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Script,
		[Parameter(Mandatory=$true, Position=1)]
		$Hostname,
		[Parameter(Mandatory=$true, Position=2)]
		$Username,
		[Parameter(Mandatory=$true, Position=3)]
		$Password,
		[Parameter(Mandatory=$true, Position=4)]
		$VIHandle
	)

	Separatorline

	$Script | ForEach-Object {Write-Output $_} | Out-String

	Separatorline

	$Output = Invoke-VMScript -ScriptText $(If ($Script.count -gt 1) {$Script -join(";")} Else {$Script}) -vm $Hostname -GuestUser $Username -GuestPassword $Password -Server $VIHandle

	Return $Output
}

# Copy a file to a VM.
function CopyFiletoServer {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Locations,
		[Parameter(Mandatory=$true, Position=1)]
		$Hostname,
		[Parameter(Mandatory=$true, Position=2)]
		$Username,
		[Parameter(Mandatory=$true, Position=3)]
		$Password,
		[Parameter(Mandatory=$true, Position=4)]
		$VIHandle,
		[Parameter(Mandatory=$true, Position=6)]
		$Upload
	)

	Separatorline

	For ($i=0; $i -le ($Locations.count/2)-1;$i++) {
		Write-Host "Sources: `n"
		Write-Output $Locations[$i*2] | Out-String
		Write-Host "Destinations: `n"
		Write-Output $Locations[($i*2)+1] | Out-String
		If ($Upload) {
			Copy-VMGuestFile -VM $Hostname -LocalToGuest -Source $($Locations[$i*2]) -Destination $($Locations[($i*2)+1]) -guestuser $Username -GuestPassword $Password -Server $VIHandle -force}
		Else {
			Copy-VMGuestFile -VM $Hostname -GuestToLocal -Source $($Locations[$i*2]) -Destination $($Locations[($i*2)+1]) -guestuser $Username -GuestPassword $Password -Server $VIHandle -force
		}
	}

	Separatorline
}

# Download the Node self signed certificate and install it in the local trusted root certificate store.
function InstallNodeRootCert {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$CertPath,
		[Parameter(Mandatory=$true, Position=1)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=2)]
		$VIHandle
	)

	SeparatorLine

	$RootCertPath = $CertPath+ "\" + $Deployment.Hostname.Split(".")[0] + "_self_signed_root_cert.crt"

	$CommandList 	= $null
	$CommandList 	= @()
	$CommandList 	+= "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`' | grep `'CN(id):`'"

	$Certid = $(ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("")[2]

	$CommandList 	= $null
	$CommandList 	= @()
	$CommandList    += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert get --id $Certid --outcert /root/vcrootcert.crt --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"

	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	$FileLocations = $null
	$FileLocations = @()
	$FileLocations += "/root/vcrootcert.crt"
	$FileLocations += $RootCertPath

	CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $false

	Import-Certificate -FilePath $RootCertPath -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

	SeparatorLine
}


# Join the VCSA to the Windows AD Domain.
function JoinADDomain {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=1)]
		$ADInfo,
		[Parameter(Mandatory=$true, Position=2)]
		$VIHandle
	)

	$PSCDeployments	= @("tiny","small","medium","large","infrastructure")

	Write-Output "== Joining $($Deployment.vmName) to the windows domain ==" | Out-String

	Separatorline

	$CommandList = $null
	$CommandList = @()
	$CommandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
	$CommandList += 'export VMWARE_LOG_DIR=/var/log'
	$CommandList += 'export VMWARE_DATA_DIR=/storage'
	$CommandList += 'export VMWARE_CFG_DIR=/etc/vmware'
	$CommandList += '/usr/bin/service-control --start --all --ignore'
	$CommandList += "/opt/likewise/bin/domainjoin-cli join " + $ADInfo.ADDomain + " " + $ADInfo.ADJoinUser + " `'" + $ADInfo.ADJoinPass + "`'"
	$CommandList += "/opt/likewise/bin/domainjoin-cli query"

	# Excute the commands in $CommandList on the vcsa.
	ExecuteScript $CommandList $Deployment.vmName "root" $Deployment.VCSARootPass $VIHandle

	Restart-VMGuest -VM $Deployment.vmName -Server $VIHandle -Confirm:$false

	# Write separator line to transcript.
	Separatorline

	# Wait 60 seconds before checking availability to make sure the vcsa is booting up and not in the process of shutting down.
	Start-Sleep -s 60

	# Wait until the vcsa is available.
	Available $("https://" + $Deployment.Hostname)

	# Write separator line to transcript.
	Separatorline

	# Check domain status.
	$CommandList = $null
	$CommandList = @()
	$CommandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
	$CommandList += 'export VMWARE_LOG_DIR=/var/log'
	$CommandList += 'export VMWARE_DATA_DIR=/storage'
	$CommandList += 'export VMWARE_CFG_DIR=/etc/vmware'
	$CommandList += '/usr/bin/service-control --start --all --ignore'
	$CommandList += "/opt/likewise/bin/domainjoin-cli query"

	# Excute the commands in $CommandList on the vcsa.
	ExecuteScript $CommandList $Deployment.vmName "root" $Deployment.VCSARootPass $VIHandle

	# if the vcsa is the first PSC in the vsphere domain, set the default identity source to the windows domain,
	# add the windows AD group to the admin groups of the PSC.
	$CommandList = $null
	$CommandList = "/opt/likewise/bin/ldapsearch -h " + $Deployment.Hostname + " -w `'" + $Deployment.VCSARootPass + "`' -x -D `"cn=Administrator,cn=Users,dc=lab-hcmny,dc=com`" -b `"cn=lab-hcmny.com,cn=Tenants,cn=IdentityManager,cn=services,dc=lab-hcmny,dc=com`" | grep vmwSTSDefaultIdentityProvider"

	$DefaultIdentitySource = $(ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput

	$VersionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$Script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $Script | Out-String

	$VIVersion = $(ExecuteScript $Script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("") | Select-String -pattern $VersionRegex

	Write-Output $VIVersion

	If ($VIVersion -match "6.7." -and $Deployment.DeployType -ne "infrastructure" -and $DefaultIdentitySource -ne $ADInfo.ADDomain) {
		# Write separator line to transcript.
		Separatorline

		ConfigureIdentity67 $Deployment $ADInfo

		Separatorline

		ConfigureSSOGroups $Deployment $ADInfo $VIHandle
	}
	ElseIf ($VIVersion -match "6.5." -and $PSCDeployments -contains $Deployment.DeployType) {
		Separatorline

		ConfigureIdentity65 $Deployment

		Separatorline

		ConfigureSSOGroups $Deployment $ADInfo $VIHandle
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

	$O = "New-OSCustomizationSpec "
	ForEach ($i in $InputObject.PSObject.Properties) {
		If ($i.Value -ne $null) {
			$O = $O.insert($O.length,"-" + $i.Name + ' "' + $i.Value + '" ')}
	}

	$O = $O -replace " `"true`"", ""
	$O = $O -replace " -ChangeSid `"false`"",""
	$O = $O -replace " -DeleteAccounts `"false`"",""
	$O = $O -replace " -vCenter "," -Server "

	Write-Output $O | out-string

	Invoke-Expression $O
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
		{$InputObject[$i].psobject.properties | Where-Object {If($_.Value -match "null") {$_.Value = $null}}}
}

# Print a dated line to standard output.
function Separatorline {
	$Date = Get-Date
	Write-Output "`n---------------------------- $Date ----------------------------`r`n" | Out-String
}

#
# Certificate functions
#

function CheckOpenSSL {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$OpenSSL
	)

	If (!(Test-Path $OpenSSL)) {Throw "Openssl required, unable to download, please install manually. Use latest OpenSSL 1.0.2."; Exit}
}

function CreatePEMFiles {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertFile,
		[Parameter(Mandatory=$true, Position=2)]
		$CerFile,
		[Parameter(Mandatory=$true, Position=3)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=4)]
		$InstanceCertDir
	)

	# Create PEM file for supplied certificate
	# Skip if we have pending cert requests
	If ($Script:CertsWaitingForApproval) {Return;}
	If (Test-Path $CertDir\chain.cer) {$ChainCer = "$CertDir\chain.cer"}
	Else {$ChainCer = "$CertDir\root64.cer"}

	If (!(Test-Path $InstanceCertDir\$SVCDir\$CertFile)) {
		Write-Host "$InstanceCertDir\$SVCDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
	}
	Else {$RUI = get-content $InstanceCertDir\$SVCDir\$CertFile
		  $ChainCont = get-content $ChainCer -encoding default
		  $RUI + $ChainCont | Out-File  $InstanceCertDir\$SVCDir\$CerFile -Encoding default
		  Write-Host "PEM file $InstanceCertDir\$SVCDir\$CerFile succesfully created" -ForegroundColor Yellow
	}
	Set-Location $CertDir
}

#
# CSR Functions
#

function CreateCSR {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CSRName,
		[Parameter(Mandatory=$true, Position=2)]
		$CFGName,
		[Parameter(Mandatory=$true, Position=3)]
		$PrivFile,
		[Parameter(Mandatory=$true, Position=4)]
		$Flag,
		[Parameter(Mandatory=$true, Position=5)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=6)]
		$Certinfo
	)

# Create RSA private key and CSR for vSphere 6.0 SSL templates
	If (!(Test-Path $CertDir\$SVCDir)) {New-Item $CertDir\$SVCDir -Type Directory}
	# vSphere 5 and 6 CSR Options are different. Set according to flag type
	# VUM 6.0 needs vSphere 5 template type
	If ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	If ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo.CompanyName
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo.CompanyName
	$MachineShort = $DEFFQDN.Split(".")[0]
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
	Set-Location $CertDir
    If (!(Test-Path $SVCDir)) {new-Item Machine -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$CertDir\$SVCDir\$CFGName" -Encoding Default -Force
    Use-OpenSSL "req -new -nodes -out `"$CertDir\$SVCDir\$CSRName`" -keyout `"$CertDir\$SVCDir\$CSRName.key`" -config `"$CertDir\$SVCDir\$CFGName`""
    Use-OpenSSL "rsa -in `"$CertDir\$SVCDir\$CSRName.key`" -out `"$CertDir\$SVCDir\$PrivFile`""
    Remove-Item $SVCDir\$CSRName.key
    Write-Host "CSR is located at $CertDir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateSolutionCSR {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CSRName,
		[Parameter(Mandatory=$true, Position=2)]
		$CFGName,
		[Parameter(Mandatory=$true, Position=3)]
		$PrivFile,
		[Parameter(Mandatory=$true, Position=4)]
		$Flag,
		[Parameter(Mandatory=$true, Position=5)]
		$SolutionUser,
		[Parameter(Mandatory=$true, Position=6)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=7)]
		$Certinfo
	)

# Create RSA private key and CSR for vSphere 6.0 SSL templates
	If (!(Test-Path $CertDir\$SVCDir)) {New-Item $CertDir\$SVCDir -Type Directory}
	# vSphere 5 and 6 CSR Options are different. Set according to flag type
	# VUM 6.0 needs vSphere 5 template type
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo.CompanyName
	If ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	If ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo.CompanyName
	$MachineShort = $DEFFQDN.Split(".")[0]
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
	Set-Location $CertDir
	If (!(Test-Path $SVCDir)) { new-Item Machine -Type Directory }
	# Create CSR and private key
	$Out = $RequestTemplate | Out-File "$CertDir\$SVCDir\$CFGName" -Encoding Default -Force
	Use-OpenSSL "req -new -nodes -out `"$CertDir\$SVCDir\$CSRName`" -keyout `"$CertDir\$SVCDir\$CSRName.key`" -config `"$CertDir\$SVCDir\$CFGName`""
	Use-OpenSSL "rsa -in `"$CertDir\$SVCDir\$CSRName.key`" -out `"$CertDir\$SVCDir\$PrivFile`""
	Remove-Item $SVCDir\$CSRName.key
    Write-Host "CSR is located at $CertDir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateVMCACSR {
# Create RSA private key and CSR
	$ComputerName = Get-WmiObject win32_computersystem
	$DEFFQDN = "$($ComputerName.Name).$($ComputerName.Domain)".ToLower()
	$VPSCFQDN = $(
		Write-Host "Is the vCenter Platform Services Controller FQDN $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new PSC FQDN"
		If ($InputFQDN) {$InputFQDN} Else {$DEFFQDN}
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
	Set-Location $CertDir
    If (!(Test-Path VMCA)) {new-Item VMCA -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$CertDir\VMCA\root_signing_cert.cfg" -Encoding Default -Force
    Use-OpenSSL "req -new -nodes -out `"$CertDir\VMCA\root_signing_cert.csr`" -keyout `"$CertDir\VMCA\vmca-org.key`" -config `"$CertDir\VMCA\root_signing_cert.cfg`""
    Use-OpenSSL "rsa -in `"$CertDir\VMCA\vmca-org.key`" -out `"$CertDir\VMCA\root_signing_cert.key`""
    Remove-Item VMCA\vmca-org.key
    Write-Host "CSR is located at $CertDir\VMCA\root_signing_cert.csr" -ForegroundColor Yellow
}

function DisplayVMDir {
	# Displays the currently used VMDir certificate via OpenSSL
	$ComputerName = Get-WmiObject win32_computersystem
	$DEFFQDN = "$($ComputerName.Name).$($ComputerName.Domain)".ToLower()
	$VMDirHost = $(
		Write-Host "Do you want to dispaly the VMDir SSL certificate of $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		If ($InputFQDN) {$InputFQDN} Else {$DEFFQDN})
	Use-OpenSSL "s_client -servername $VMDirHost -connect `"${VMDirHost}:636`""
}

function DownloadRoots {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertInfo
	)

	# Create credential from username and password.
    If ($CertInfo.Username) {
        $SecPasswd = ConvertTo-SecureString $Certinfo.Password -AsPlainText -Force
        $Creds = New-Object System.Management.Automation.PSCredential ($CertInfo.Username, $SecPasswd)
    }

	# Select the Certificate Authority furthest from Root to download the chain certificate from.
    If ($CertInfo.SubCA2) {$CA = $CertInfo.SubCA2}
    ElseIf ($CertInfo.SubCA1) {$CA = $CertInfo.SubCA1}
    Else {$CA = $CertInfo.RootCA}

	# Check to see if the CA is using TCP port 443 or 80.
    If ((Test-NetConnection -ComputerName $CA -Port 443 -ErrorAction Ignore -InformationLevel Quiet).TCPTestSucceeded) {$SSL = "https"} Else {$SSL = "http"}

	# Set the URL to use HTTPS or HTTP based on previous test. (Note: The '-1' in Renewal=-1 indicates that it will download the current certificate.)
	$URL = $SSL + ':' + "//$($CA)/certsrv/certnew.p7b?ReqID=CACert&Renewal=-1&Enc=DER"

	# If there are Credentials, use them otherwise try to download the certificate without them.
    If ($CertInfo.Username) {
        Invoke-WebRequest -Uri $URL -OutFile "$CertDir\certnew.p7b" -Credential $Creds
    }
    Else {
        Invoke-WebRequest -Uri $URL -OutFile "$CertDir\certnew.p7b"
    }

	# Define empty array.
  	$CACerts = @()

	# Call Use-OpenSSL to convert the p7b certificate to PEM and split the string on '-', then remove any zero length items.
	$P7BChain = (Use-OpenSSL "pkcs7 -inform PEM -outform PEM -in `"$CertDir\certnew.p7b`" -print_certs").Split("-") | Where-Object {$_.Length -gt 0}

	# Find the index of all the BEGIN CERTIFICATE lines.
	$Index = (0..($P7BChain.count - 1)) | Where-Object {$P7BChain[$_] -match "BEGIN CERTIFICATE"}

	# Extract the Certificates and append the BEGIN CERTIFICATE and END CERTIFICATE lines.
	ForEach ($i in $Index) {
		$CACerts += $P7BChain[$i+1].insert($P7BChain[$i+1].length,'-----END CERTIFICATE-----').insert(0,'-----BEGIN CERTIFICATE-----')
	}

	# Save the PEM Chain certificate.
	$CACerts | Set-Content -Path "$CertDir\chain.cer" -Encoding ascii

	# Save the Root and Intermidiate Certificates.
	Switch ($CACerts.Count)
	{
		1	{	$CACerts[0] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}

		2	{	$CACerts[0] | Set-Content -Path "$CertDir\interm64.cer"		-Encoding ascii
				$CACerts[1] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}

		3	{	$CACerts[0] | Set-Content -Path "$CertDir\interm264.cer"	-Encoding ascii
				$CACerts[1] | Set-Content -Path "$CertDir\interm64.cer"		-Encoding ascii
				$CACerts[2] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}
	}
}

function MoveUserCerts {
	Get-ChildItem -Path $CertDir -filter "*.crt" | ForEach-Object {
		$Dir = $_.Basename
		If (!(Test-Path $CertDir\$Dir)) {New-Item $CertDir\$Dir -Type Directory}
		Move-Item -Path $_.FullName -Destination $CertDir\$Dir -Force
	}
	Get-ChildItem -Path $CertDir -filter "*.key" | ForEach-Object {
		$Dir = $_.Basename
		Move-Item -Path $_.FullName -Destination $CertDir\$Dir -Force
	}
}

function OnlineMint {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CSRFile,
		[Parameter(Mandatory=$true, Position=2)]
		$CertFile,
		[Parameter(Mandatory=$true, Position=3)]
		$Template,
		[Parameter(Mandatory=$true, Position=4)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=5)]
		$IssuingCA
	)

# Mint certificates from online Microsoft CA
    # initialize objects to use for external processes
    $PSI = New-Object System.Diagnostics.ProcessStartInfo
    $PSI.CreateNoWindow = $true
    $PSI.UseShellExecute = $false
    $PSI.RedirectStandardOutput = $true
    $PSI.RedirectStandardError = $true
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $PSI
    $Script:certsWaitingForApproval = $false
        # submit the CSR to the CA
        $PSI.FileName = "certreq.exe"
        $PSI.Arguments = @("-submit -attrib `"$Template`" -config `"$IssuingCA`" -f `"$CertDir\$SVCDir\$CSRFile`" `"$CertDir\$SVCDir\$CertFile`"")
		Write-Host ""
        Write-Host "Submitting certificate request for $SVCDir..." -ForegroundColor Yellow
        [void]$Process.Start()
        $CMDOut = $Process.StandardOutput.ReadToEnd()
        If ($CMDOut.Trim() -like "*request is pending*")
        {
            # Output indicates the request requires approval before we can download the signed cert.
            $Script:CertsWaitingForApproval = $true
            # So we need to save the request ID to use later once they're approved.
            $ReqID = ([regex]"RequestId: (\d+)").Match($CMDOut).Groups[1].Value
            If ($ReqID.Trim() -eq [String]::Empty)
            {
                Write-Error "Unable to parse RequestId from output."
                Write-Debug $CMDOut
                Exit
            }
            Write-Host "RequestId: $ReqID is pending" -ForegroundColor Yellow
            # Save the request ID to a file that OnlineMintResume can read back in later
            $ReqID | Out-File "$CertDir\$SVCDir\requestid.txt"
        }
        Else
        {
            # Output doesn't indicate a pending request, so check for a signed cert file
            If (!(Test-Path $CertDir\$SVCDir\$CertFile)) {
                Write-Error "Certificate request failed or was unable to download the signed certificate."
                Write-Error "Verify that the ISSUING_CA variable is set correctly."
                Write-Debug $CMDOut
                Exit
            }
            Else { Write-Host "Certificate successfully downloaded." -ForegroundColor Yellow}
        }
    if ($Script:CertsWaitingForApproval) {
        Write-Host
        Write-Host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host "Contact your CA administrator to approve the request ID(s) listed above." -ForegroundColor Yellow
        Write-Host "To resume use the appropriate option from the menu." -ForegroundColor Yellow
    }
}

function OnlineMintResume {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertFile
	)

# Resume the minting process for certificates from online Microsoft CA that required approval
    # initialize objects to use for external processes
    $PSI = New-Object System.Diagnostics.ProcessStartInfo
    $PSI.CreateNoWindow = $true
    $PSI.UseShellExecute = $false
    $PSI.RedirectStandardOutput = $true
    $PSI.RedirectStandardError = $true
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $PSI
    $Script:CertsWaitingForApproval = $false
    # skip if there's no requestid.txt file
    If (!(Test-Path "$CertDir\$SVCDir\requestid.txt")) {Continue}
    $ReqID = Get-Content "$CertDir\$SVCDir\requestid.txt"
    Write-Verbose "Found RequestId: $ReqID for $SVCDir"
    # retrieve the signed certificate
    $PSI.FileName = "certreq.exe"
    $PSI.Arguments = @("-retrieve -f -config `"$IssuingCA`" $ReqID `"$CertDir\$SVCDir\$CertFile`"")
    Write-Host "Downloading the signed $SVCDir certificate..." -ForegroundColor Yellow
    [void]$Process.Start()
    $CMDOut = $Process.StandardOutput.ReadToEnd()
    If (!(Test-Path "$CertDir\$SVCDir\$CertFile")) {
        # it's not there, so check if the request is still pending
        If ($CMDOut.Trim() -like "*request is pending*") {
            $Script:CertsWaitingForApproval = $true
            Write-Host "RequestId: $ReqID is pending" -ForegroundColor Yellow
        }
        Else
        {
			Write-Warning "There was a problem downloading the signed certificate" -foregroundcolor red
			Write-Warning $CMDOut
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

function Use-Openssl {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$OpenSSLArgs
	)

	$OpenSSLInfo = $null
	$O			 = $null
	$OpenSSLInfo = New-Object System.Diagnostics.ProcessStartInfo
	$OpenSSLInfo.FileName = $OpenSSL
	$OpenSSLInfo.RedirectStandardError = $true
	$OpenSSLInfo.RedirectStandardOutput = $true
	$OpenSSLInfo.UseShellExecute = $false
	$OpenSSLInfo.Arguments = $OpenSSLArgs
	$O = New-Object System.Diagnostics.Process
	$O.StartInfo = $OpenSSLInfo
	$O.Start() | Out-Null
	$O.WaitForExit()
	$StdOut = $O.StandardOutput.ReadToEnd()
	$StdErr = $O.StandardError.ReadToEnd()
	Write-Host "stdout: $StdOut"
	Write-Host "stderr: $StdErr"
	Write-Host "exit code: " + $O.ExitCode
	Return $StdOut
}

function TransferCertToNode {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$RootCertDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=2)]
		$Deployment,
		[Parameter(Mandatory=$true, Position=3)]
		$VIHandle,
		[Parameter(Mandatory=$false, Position=4)]
		$DeploymentParent
	)

	# http://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.security.doc/GUID-BD70615E-BCAA-4906-8E13-67D0DBF715E4.html
	# Copy SSL certificates to a VCSA and replace the existing ones.

	$PSCDeployments	= @("tiny","small","medium","large","infrastructure")

	$CertPath		= "$CertDir\" + $Deployment.Hostname
	$SSLPath		= "/root/ssl"
	$SolutionPath	= "/root/solutioncerts"
	$Script 		= "mkdir $SSLPath;mkdir $SolutionPath"

	ExecuteScript $Script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	$VersionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'
	$Script 	  = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"

	Write-Output $Script | Out-String

	$VIVersion = $(ExecuteScript $Script $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("") | Select-String -pattern $VersionRegex

	Write-Output $VIVersion

	$FileLocations = $null
	$FileLocations = @()
    $FileLocations += "$CertPath\machine\new_machine.crt"
	$FileLocations += "$SSLPath/new_machine.crt"
	$FileLocations += "$CertPath\machine\new_machine.cer"
	$FileLocations += "$SSLPath/new_machine.cer"
	$FileLocations += "$CertPath\machine\ssl_key.priv"
	$FileLocations += "$SSLPath/ssl_key.priv"
	If ($PSCDeployments -contains $Deployment.DeployType) {
		If (Test-Path -Path "$RootCertDir\root64.cer") {
			$FileLocations += "$RootCertDir\root64.cer"
			$FileLocations += "$SSLPath/root64.cer"}
		If (Test-Path -Path "$RootCertDir\interm64.cer") {
			$FileLocations += "$RootCertDir\interm64.cer"
			$FileLocations += "$SSLPath/interm64.cer"}
		If (Test-Path -Path "$RootCertDir\interm264.cer") {
		$FileLocations += "$RootCertDir\interm264.cer"
		$FileLocations += "$SSLPath/interm264.cer"}}

	If (Test-Path -Path "$RootCertDir\interm64.cer") {
		$FileLocations += "$RootCertDir\chain.cer"
		$FileLocations += "$SSLPath/chain.cer"}

	$FileLocations += "$CertPath\solution\machine.cer"
	$FileLocations += "$SolutionPath/machine.cer"
	$FileLocations += "$CertPath\solution\machine.priv"
	$FileLocations += "$SolutionPath/machine.priv"
	$FileLocations += "$CertPath\solution\vsphere-webclient.cer"
	$FileLocations += "$SolutionPath/vsphere-webclient.cer"
	$FileLocations += "$CertPath\solution\vsphere-webclient.priv"
	$FileLocations += "$SolutionPath/vsphere-webclient.priv"
	If ($Deployment.DeployType -ne "Infrastructure") {
		$FileLocations += "$CertPath\solution\vpxd.cer"
		$FileLocations += "$SolutionPath/vpxd.cer"
		$FileLocations += "$CertPath\solution\vpxd.priv"
		$FileLocations += "$SolutionPath/vpxd.priv"
		$FileLocations += "$CertPath\solution\vpxd-extension.cer"
		$FileLocations += "$SolutionPath/vpxd-extension.cer"
		$FileLocations += "$CertPath\solution\vpxd-extension.priv"
		$FileLocations += "$SolutionPath/vpxd-extension.priv"}

	CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle $true

	$CommandList = $null
	$CommandList = @()

	# Set path for python.
	$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$CommandList += "export VMWARE_LOG_DIR=/var/log"
	$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
	$CommandList += "export VMWARE_DATA_DIR=/storage"
	# Stop all services.
	$CommandList += "service-control --stop --all"
	# Start vmafdd,vmdird, and vmca services.
	$CommandList += "service-control --start vmafdd"
	If ($PSCDeployments -contains $Deployment.DeployType) {
		$CommandList += "service-control --start vmdird"
		$CommandList += "service-control --start vmca"
	}

	# Replace the root cert.
	If ($PSCDeployments -contains $Deployment.DeployType) {
		If (Test-Path -Path "$RootCertDir\root64.cer") {
			$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SSLPath/root64.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}
		If (Test-Path -Path "$RootCertDir\interm64.cer") {
			$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SSLPath/interm64.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}
		If (Test-Path -Path "$RootCertDir\interm264.cer") {
			$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SSLPath/interm264.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}}

	# Add certIficate chain to TRUSTED_ROOTS of the PSC for ESXi Cert Replacement.
	# If ($PSCDeployments -contains $Deployment.DeployType -and (Test-Path -Path "$RootCertDir\interm64.cer")) {
	<#If ($Deployment.DeployType -eq "Infrastructure" -and (Test-Path -Path "$RootCertDir\interm64.cer")) {
		$CommandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry create --store TRUSTED_ROOTS --alias chain.cer --cert $SSLPath/chain.cer"
	}#>

	# Retrive the Old Machine Cert and save its thumbprint to a file.
	$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store MACHINE_SSL_CERT --alias __MACHINE_CERT --output $SSLPath/old_machine.crt"
	$CommandList += "openssl x509 -in $SSLPath/old_machine.crt -noout -sha1 -fingerprint > $SSLPath/thumbprint.txt"

    # Replace the Machine Cert.
	$CommandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store MACHINE_SSL_CERT --alias __MACHINE_CERT"
	$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store MACHINE_SSL_CERT --alias __MACHINE_CERT --cert $SSLPath/new_machine.cer --key $SSLPath/ssl_key.priv"

	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	$CommandList = $null
	$CommandList = @()
	$CommandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vsphere-webclient --alias vsphere-webclient"
	$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vsphere-webclient --alias vsphere-webclient --cert $SolutionPath/vsphere-webclient.cer --key $SolutionPath/vsphere-webclient.priv"
	# Skip If server is an External PSC. - vpxd and vpxd-extension do not need to be replaced on an external PSC.
	If ($Deployment.DeployType -ne "Infrastructure") {
		$CommandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd --alias vpxd"
		$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd --alias vpxd --cert $SolutionPath/vpxd.cer --key $SolutionPath/vpxd.priv"
		$CommandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd-extension --alias vpxd-extension"
		$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd-extension --alias vpxd-extension --cert $SolutionPath/vpxd-extension.cer --key $SolutionPath/vpxd-extension.priv"
	}

	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	$CommandList = $null
	$CommandList = @()
	$CommandList += "/usr/lib/vmware-vmafd/bin/vmafd-cli get-machine-id --server-name localhost"
	$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli service list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"

	$UniqueID = Invoke-VMScript -ScriptText $CommandList[0] -vm $Deployment.Hostname -GuestUser "root" -GuestPassword $Deployment.VCSARootPass -Server $VIHandle
	$CertList = Invoke-VMScript -ScriptText $CommandList[1] -vm $Deployment.Hostname -GuestUser "root" -GuestPassword $Deployment.VCSARootPass -Server $VIHandle

	Separatorline

	Write-Output "Unique ID: " + $UniqueID | Out-String
	Write-Output "Certificate List: " + $CertList | Out-String

	Separatorline

	# Retrieve unique key list relevant to the server.
	$SolutionUsers = ($Certlist.ScriptOutput.Split(".").Split("`n") | ForEach-Object {If($_[0] -eq " ") {$_}} | Where-Object {$_.ToString() -like "*$($UniqueID.ScriptOutput.Split("`n")[0])*"}).Trim(" ")

	Separatorline

	Write-Output "Solution Users: " + $SolutionUsers | Out-String

	Separatorline

	$CommandList = $null
	$CommandList = @()

	$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[1] + " --cert $SolutionPath/vsphere-webclient.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
	If ($Deployment.DeployType -ne "Infrastructure") {
		$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[2] + " --cert $SolutionPath/vpxd.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
		$CommandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $SolutionUsers[3] + " --cert $SolutionPath/vpxd-extension.cer --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"}

	# Set path for python.
	$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$CommandList += "export VMWARE_LOG_DIR=/var/log"
	$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
	$CommandList += "export VMWARE_DATA_DIR=/storage"
	# Start all services.
	$CommandList += "service-control --start --all --ignore"

	# Service update
	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

	Start-Sleep -Seconds 10

	If ($Deployment.DeployType -ne "Infrastructure") {
		$CommandList = $null
		$CommandList = @()
		# Set path for python.
		$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$CommandList += "export VMWARE_LOG_DIR=/var/log"
		$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
		$CommandList += "export VMWARE_DATA_DIR=/storage"
		# Replace EAM Solution User Cert.
		$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.crt"
		$CommandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getkey --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.key"
		$CommandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.vim.eam -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s " + $Deployment.Hostname + " -u administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`'"
		$CommandList += '/usr/bin/service-control --stop vmware-eam'
		$CommandList += '/usr/bin/service-control --start vmware-eam'

		# Service update
		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
	}

    # Update VAMI Certs on External PSC.
	$CommandList = $null
	$CommandList = @()
   	$CommandList += "/usr/lib/applmgmt/support/scripts/postinstallscripts/setup-webserver.sh"

	# Service update
	ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle

    # Refresh Update Manager CertIficates.
	If ($VIVersion -match "6.5." -and $Deployment.DeployType -ne "Infrastructure") {
    	$CommandList = $null
		$CommandList = @()
		# Set path for python.
		$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$CommandList += "export VMWARE_LOG_DIR=/var/log"
		$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
		$CommandList += "export VMWARE_DATA_DIR=/storage"
		$CommandList += "export VMWARE_RUNTIME_DATA_DIR=/var"
    	$CommandList += "/usr/lib/vmware-updatemgr/bin/updatemgr-util refresh-certs"
    	$CommandList += "/usr/lib/vmware-updatemgr/bin/updatemgr-util register-vc"


    	# Service update
		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
	}

    # Refresh Update Manager CertIficates.
	If ($VIVersion -match "6.7." -and $Deployment.DeployType -ne "Infrastructure") {

		$Script = "echo `'$Deployment.VCSARootPass`' | appliancesh com.vmware.updatemgr-util register-vc"

    	# Service update
		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
	}

 	# Assign the original machine certIficate thumbprint to $ThumbPrint and remove the carriage return.
    # Change the shell to Bash to enable scp and retrieve the original machine certIficate thumbprint.
    $CommandList = $null
    $CommandList = @()
    $CommandList += "chsh -s /bin/bash"
    $CommandList += "cat /root/ssl/thumbprint.txt"
    $ThumbPrint = $(ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle).Scriptoutput.Split("=",2)[1]
	$ThumbPrint = $ThumbPrint -replace "`t|`n|`r",""

    # Register new certIficates with VMWare Lookup Service - KB2121701 and KB2121689.
	If ($PSCDeployments -contains $Deployment.DeployType) {
        # Register the new machine thumbprint with the lookup service.
        $CommandList = $null
        $CommandList = @()
		# Set path for python.
        $CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $CommandList += "export VMWARE_LOG_DIR=/var/log"
        $CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $CommandList += "export VMWARE_DATA_DIR=/storage"
		$CommandList += "export VMWARE_JAVA_HOME=/usr/java/jre-vmware"
		# Register the new machine thumprint.
        $CommandList += "python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $Deployment.Hostname + "/lookupservice/sdk --fingerprint $ThumbPrint --certfile /root/ssl/new_machine.crt --user administrator@" + $Deployment.SSODomainName + " --password `'" + $Deployment.SSOAdminPass + "`'"

        Write-Output $CommandList | Out-String

        ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle}
    Else {
		  # If the VCSA vCenter does not have an embedded PSC Register its Machine CertIficate with the External PSC.
          Write-Output $DeploymentParent | Out-String

          # SCP the new vCenter machine certIficate to the external PSC and register it with the VMWare Lookup Service via SSH.
              $CommandList = $null
			  $CommandList = @()
			  $CommandList += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $DeploymentParent.Hostname + " mkdir /root/ssl"
              $CommandList += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' scp -oStrictHostKeyChecking=no /root/ssl/new_machine.crt root@" + $DeploymentParent.Hostname + ":/root/ssl/new_" + $Deployment.Hostname + "_machine.crt"
			  $CommandList += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $DeploymentParent.Hostname + " `"python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $DeploymentParent.Hostname + "/lookupservice/sdk --fingerprint $ThumbPrint --certfile /root/ssl/new_" + $Deployment.Hostname + "_machine.crt --user administrator@" + $DeploymentParent.SSODomainName + " --password `'" + $DeploymentParent.SSOAdminPass + "`'`""
			  $CommandList += "sshpass -p `'" + $DeploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $DeploymentParent.Hostname + " rm -r /root/ssl"

              Write-Output $CommandList | Out-String

              ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $VIHandle
    }

}

function UserPEMFiles {
	# Creates PEM files for all solution user certificates
	Get-ChildItem -Path $CertDir -filter "*.csr" | ForEach-Object {
		$Dir = $_.Basename
		CreatePEMFiles $Dir "$Dir.crt" "$Dir.cer"
	}

}

function VMDirRename {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$CertDir
	)
	# Renames SSL certificate files to those used by VCSA
	Rename-Item $CertDir\VMDir\VMDir.cer vmdircert.pem
	Rename-Item $CertDir\VMDir\VMDir.priv vmdirkey.pem
	Write-Host "Certificate files renamed. Upload \VMDir\vmdircert.pem and \VMDir\vmdirkey.pem" -ForegroundColor Yellow
	Write-Host "to VCSA at /usr/lib/vmware-dir/share/config" -ForegroundColor Yellow
}

function VMCAMint {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$SVCDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CFGFile,
		[Parameter(Mandatory=$true, Position=2)]
		$CertFile,
		[Parameter(Mandatory=$true, Position=3)]
		$PrivFile
	)

	# This function issues a new SSL certificate from the VMCA.
	If(!(Test-Path $CertDir\$SVCDir)) {New-Item $CertDir\$SVCDir -Type Directory}
	$ComputerName = Get-WmiObject win32_computersystem
	$DEFFQDN = "$($ComputerName.name).$($ComputerName.domain)".ToLower()
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
	$Out = $VMWTemplate | Out-File "$CertDir\$SVCDir\$CFGFile" -Encoding Default -Force
	# Mint certificate from VMCA and save to disk
	Set-Location "C:\Program Files\VMware\vCenter Server\vmcad"
	.\certool --genkey --privkey=$CertDir\$SVCDir\$PrivFile --pubkey=$CertDir\$SVCDir\$SVCDir.pub
	.\certool --gencert --cert=$CertDir\$SVCDir\$CertFile --privkey=$CertDir\$SVCDir\$PrivFile --config=$CertDir\$SVCDir\$CFGFile --server=$PSCFQDN
	If (Test-Path $CertDir\$SVCDir\$CertFile) {Write-Host "PEM file located at $CertDir\$SVCDir\new_machine.cer" -ForegroundColor Yellow n}
}

function CDDir {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$FolderPath
	)

	# CDs into the directory the Toolkit script was run
	Set-Location $FolderPath
}

function CreateVCSolutionCert {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$RootCertDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=2)]
		$InstanceCertDir,
		[Parameter(Mandatory=$true, Position=3)]
		$Certinfo
	)

	CreateSolutionCSR Solution vpxd.csr vpxd.cfg vpxd.priv 6 vpxd $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vpxd-extension.csr vpxd-extension.cfg vpxd-extension.priv 6 vpxd-extension $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo

	OnlineMint Solution vpxd.csr vpxd.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vpxd-extension.csr vpxd-extension.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution machine.csr machine.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA

	CreatePEMFiles Solution vpxd.crt vpxd.cer $RootCertDir $InstanceCertDir
	CreatePEMFiles Solution vpxd-extension.crt vpxd-extension.cer $RootCertDir $InstanceCertDir
	CreatePEMFiles Solution machine.crt machine.cer $RootCertDir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $RootCertDir $InstanceCertDir
}

function CreatePscSolutionCert {
	Param (
		[Parameter(Mandatory=$true, Position=0)]
		$RootCertDir,
		[Parameter(Mandatory=$true, Position=1)]
		$CertDir,
		[Parameter(Mandatory=$true, Position=2)]
		$InstanceCertDir,
		[Parameter(Mandatory=$true, Position=3)]
		$Certinfo
	)

	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo

	OnlineMint Solution machine.csr machine.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Certinfo.V6Template $InstanceCertDir $Certinfo.IssuingCA

	CreatePEMFiles Solution machine.crt machine.cer $RootCertDir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $RootCertDir $InstanceCertDir
}

# End Functions

# PSScriptRoot does not have a trailing "\"
Write-Output $FolderPath | Out-String

# Start New Transcript
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Continue"
$LogPath = "$FolderPath\Logs\" + $(Get-Date -format "MM-dd-yyyy_HH-mm")
If (!(Test-Path $LogPath)) {New-Item $LogPath -Type Directory}
$OutputPath = "$LogPath\InitialState_" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
Start-Transcript -path $OutputPath -append

Separatorline

# Check to see if Powershell is at least version 3.0
$PSPath = "HKLM:\SOFTWARE\Microsoft\PowerShell\3"
If (!(Test-Path $PSPath)) {
	Write-Host "PowerShell 3.0 or higher required. Please install"; Exit
}

# Load Powercli Modules
If (Get-Module -ListAvailable | Where-Object {$_.Name -match "VMware.PowerCLI"}) {
	Import-Module VMware.PowerCLI
}
Else {
		If (Get-Command Install-Module -ErrorAction SilentlyContinue) {
			Install-Module -Name VMware.PowerCLI -Confirm:$false
		}
		Else
		{Exit}
}

If (Get-Module -ListAvailable | Where-Object {$_.Name -match "powershell-yaml"}) {
	Import-Module powershell-yaml
}
Else {
		If (Get-Command Install-Module -ErrorAction SilentlyContinue) {
			Install-Module -Name powershell-yaml -Confirm:$false
		}
		Else
		{Exit}
}

Separatorline

# Check the version of Ovftool and get it's path. Search C:\program files\ and C:\Program Files (x86)\ subfolders for vmware and find the
# Ovftool folders. Then check the version and return the first one that is version 4 or higher.
$OvfToolPath = (Get-ChildItem (Get-ChildItem $env:ProgramFiles, ${env:ProgramFiles(x86)} -filter vmware).fullname -recurse -filter ovftool.exe | ForEach-Object {If(!((& $($_.DirectoryName + "\ovftool.exe") --version).Split(" ")[2] -lt 4.0.0)) {$_}} | Select-Object -first 1).DirectoryName

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
                    If ($s_Certinfo.SubCA1 -eq "null") {$s_Certinfo.SubCA1 = $null}
                    If ($s_Certinfo.SubCA2 -eq "null") {$s_Certinfo.SubCA2 = $null}
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
			$ObjExcel	= $null

			[System.GC]::Collect()
			[System.GC]::WaitForPendingFinalizers()
		}

	'json' {
			$Json_Dir = $FolderPath + "\Json"
			$SrcADInfo				= Get-Content -Raw -Path "$Json_Dir\ad-info.json" 			| ConvertFrom-Json
			$SrcPlugins				= Get-Content -Raw -Path "$Json_Dir\plugins.json"			| ConvertFrom-Json
			$SrcAutoDepRules		= Get-Content -Raw -Path "$Json_Dir\autodeploy-rules.json"	| ConvertFrom-Json
			$SrcCertInfo			= Get-Content -Raw -Path "$Json_Dir\cert-info.json"			| ConvertFrom-Json
			$SrcClusters			= Get-Content -Raw -Path "$Json_Dir\cluster-info.json"		| ConvertFrom-Json
			$SrcFolders				= Get-Content -Raw -Path "$Json_Dir\folders.json"			| ConvertFrom-Json
			$SrcPermissions			= Get-Content -Raw -Path "$Json_Dir\permissions.json"		| ConvertFrom-Json
			$SrcOSCustomizations	= Get-Content -Raw -Path "$Json_Dir\os-customizations.json"	| ConvertFrom-Json
			$SrcDeployments			= Get-Content -Raw -Path "$Json_Dir\deployments.json"		| ConvertFrom-Json
			$SrcLicenses			= Get-Content -Raw -Path "$Json_Dir\licenses.json"			| ConvertFrom-Json
			$SrcRoles				= Get-Content -Raw -Path "$Json_Dir\roles.json"				| ConvertFrom-Json
			$SrcServices			= Get-Content -Raw -Path "$Json_Dir\services.json"			| ConvertFrom-Json
			$SrcSites				= Get-Content -Raw -Path "$Json_Dir\sites.json"				| ConvertFrom-Json
			$SrcVDSwitches			= Get-Content -Raw -Path "$Json_Dir\vdswitches.json"		| ConvertFrom-Json
			$SrcVLANS				= Get-Content -Raw -Path "$Json_Dir\vlans.json"				| ConvertFrom-Json
			$SrcSummary      	    = Get-Content -Raw -Path "$Json_Dir\summary.json"			| ConvertFrom-Json
		}

	'yaml' {
			$Yaml_Dir = $FolderPath + "\Yaml"
			$SrcADInfo				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\ad-info.yml" 	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcPlugins				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\plugins.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcAutoDepRules		= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\autodeploy-rules.yml"  | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcCertInfo			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cert-info.yml"		    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcClusters			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\cluster-info.yml"      | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcFolders				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\folders.yml"	        | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcPermissions			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\permissions.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcOSCustomizations	= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\os-customizations.yml"	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcDeployments			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\deployments.yml"	    | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcLicenses			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\licenses.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcRoles				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\roles.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcServices			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\services.yml"    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcSites				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\sites.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcVDSwitches			= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vdswitches.yml"  		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcVLANS				= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\vlans.yml"	    		| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
			$SrcSummary         	= [pscustomobject](Get-Content -Raw -Path "$Yaml_Dir\summary.yml"	    	| ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)

            # Change ":" Colon to commas for Vlan Network Properties.
			For ($i=0;$i -lt ($SrcVLANS | Measure-Object).count;$i++) {
				$SrcVLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
			}
		}
}

Write-Output $SrcADInfo				| Out-String
Separatorline
Write-Output $SrcPlugins			| Out-String
Separatorline
Write-Output $SrcAutoDepRules		| Out-String
Separatorline
Write-Output $SrcCertInfo			| Out-String
Separatorline
Write-Output $SrcClusters			| Out-String
Separatorline
Write-Output $SrcFolders			| Out-String
Separatorline
Write-Output $SrcPermissions		| Out-String
Separatorline
Write-Output $SrcOSCustomizations	| Out-String
Separatorline
Write-Output $SrcDeployments		| Out-String
Separatorline
Write-Output $SrcLicenses			| Out-String
Separatorline
Write-Output $SrcRoles				| Out-String
Separatorline
Write-Output $SrcServices			| Out-String
Separatorline
Write-Output $SrcSites				| Out-String
Separatorline
Write-Output $SrcVDSwitches			| Out-String
Separatorline
Write-Output $SrcVLANS				| Out-String
Separatorline
Write-Output $SrcSummary			| Out-String
Separatorline

# Password Scrub array for redacting passwords from Transcript.
If ($SrcSummary.TranscriptScrub) {
    $Scrub = @()
    $Scrub += $SrcADInfo.ADJoinPass
    $Scrub += $SrcADInfo.ADvmcamPass
    $Scrub += $SrcAutoDepRules.ProfileRootPassword
	$Scrub += $SrcOSCustomizations.AdminPassword
	$Scrub += $SrcOSCustomizations.DomainPassword
    $Scrub += $SrcDeployments.VCSARootPass
    $Scrub += $SrcDeployments.esxiRootPass
    $Scrub += $SrcDeployments.SSOAdminPass
}

### Save to Excel
If ($Source -ne 1 -and $Export) {
	$ExcelFilePathDst = "$FolderPath\$ExcelFileName"
	If (Test-Path -Path $ExcelFilePathDst) {Remove-Item -Path $ExcelFilePathDst -Confirm:$false -Force}

	$ObjExcelDst = New-Object -ComObject Excel.Application
	$ObjExcelDst.Visible = $false
	$WorkBookDst = $ObjExcelDst.Workbooks.Add()
	$WorkSheetcount = 16 - ($WorkBookDst.worksheets | measure-object).count

	# http://www.planetcobalt.net/sdb/vba2psh.shtml
	$def = [Type]::Missing
	$null = $ObjExcelDst.Worksheets.Add($def,$def,$WorkSheetcount,$def)

	ConvertPSObjectToExcel -InputObject $SrcVLANS -WorkSheet $WorkBookDst.Worksheets.Item("Sheet3") -SheetName "vlans" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcVDSwitches -WorkSheet $WorkBookDst.Worksheets.Item("Sheet2") -SheetName "vdswitches" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcDeployments-WorkSheet $WorkBookDst.Worksheets.Item("Sheet1") -SheetName "vcsa" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcSites -WorkSheet $WorkBookDst.Worksheets.Item("Sheet4") -SheetName "sites" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcServices -WorkSheet $WorkBookDst.Worksheets.Item("Sheet5") -SheetName "services" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcRoles -WorkSheet $WorkBookDst.Worksheets.Item("Sheet6") -SheetName "roles" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcPlugins -WorkSheet $WorkBookDst.Worksheets.Item("Sheet7") -SheetName "plugins" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcPermissions -WorkSheet $WorkBookDst.Worksheets.Item("Sheet8") -SheetName "permissions" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcOSCustomizations -WorkSheet $WorkBookDst.Worksheets.Item("Sheet9") -SheetName "OS" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcLicenses -WorkSheet $WorkBookDst.Worksheets.Item("Sheet10") -SheetName "licenses" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcFolders -WorkSheet $WorkBookDst.Worksheets.Item("Sheet11") -SheetName "folders" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcClusters -WorkSheet $WorkBookDst.Worksheets.Item("Sheet12") -SheetName "clusters" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcCertInfo -WorkSheet $WorkBookDst.Worksheets.Item("Sheet13") -SheetName "certs" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcAutoDepRules -WorkSheet $WorkBookDst.Worksheets.Item("Sheet14") -SheetName "autodeploy" -Excelpath $ExcelFilePathDst
	ConvertPSObjectToExcel -InputObject $SrcADInfo -WorkSheet $WorkBookDst.Worksheets.Item("Sheet15") -SheetName "adinfo" -Excelpath $ExcelFilePathDst
    ConvertPSObjectToExcel -InputObject $SrcSummary -WorkSheet $WorkBookDst.Worksheets.Item("Sheet16") -SheetName "summary" -Excelpath $ExcelFilePathDst

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
If ($Source -ne 2 -and $Export) {
	If (!(Test-Path -Path "$FolderPath\Json")) {New-Item "$FolderPath\Json" -Type Directory}
	SaveToJson -InputObject $SrcADInfo -FilePath "$FolderPath\ad-info.json"
	SaveToJson -InputObject $SrcPlugins -FilePath "$FolderPath\plugins.json"
	SaveToJson -InputObject $SrcAutoDepRules -FilePath "$FolderPath\autodeploy-rules.json"
	SaveToJson -InputObject $SrcCertInfo -FilePath "$FolderPath\cert-info.json"
	SaveToJson -InputObject $SrcClusters -FilePath "$FolderPath\cluster-info.json"
	SaveToJson -InputObject $SrcFolders -FilePath "$FolderPath\folders.json"
	SaveToJson -InputObject $SrcPermissions -FilePath "$FolderPath\permissions.json"
	SaveToJson -InputObject $SrcOSCustomizations -FilePath "$FolderPath\os-customizations.json"
	SaveToJson -InputObject $SrcDeployments-FilePath "$FolderPath\deployments.json"
	SaveToJson -InputObject $SrcLicenses -FilePath "$FolderPath\licenses.json"
	SaveToJson -InputObject $SrcRoles -FilePath "$FolderPath\roles.json"
    SaveToJson -InputObject $SrcServices -FilePath "$FolderPath\services.json"
    SaveToJson -InputObject $SrcSites -FilePath "$FolderPath\sites.json"
    SaveToJson -InputObject $SrcVDSwitches -FilePath "$FolderPath\vdswitches.json"
    SaveToJson -InputObject $SrcVLANS -FilePath "$FolderPath\vlans.json"
    SaveToJson -InputObject $SrcSummary -FilePath "$FolderPath\summary.json"
}

### Save to Yaml
If ($Source -ne 3 -and $Export) {
	If (!(Test-Path -Path "$FolderPath\Yaml")) {New-Item "$FolderPath\Yaml" -Type Directory}
	SaveToYaml -InputObject $SrcADInfo -FilePath "$FolderPath\ad-info.yml"
	SaveToYaml -InputObject $SrcPlugins -FilePath "$FolderPath\plugins.yml"
	SaveToYaml -InputObject $SrcAutoDepRules -FilePath "$FolderPath\autodeploy-rules.yml"
	SaveToYaml -InputObject $SrcCertInfo -FilePath "$FolderPath\cert-info.yml"
	SaveToYaml -InputObject $SrcClusters -FilePath "$FolderPath\cluster-info.yml"
	SaveToYaml -InputObject $SrcFolders -FilePath "$FolderPath\folders.yml"
	SaveToYaml -InputObject $SrcPermissions -FilePath "$FolderPath\permissions.yml"
	SaveToYaml -InputObject $SrcOSCustomizations -FilePath "$FolderPath\os-customizations.yml"
	SaveToYaml -InputObject $SrcDeployments-FilePath "$FolderPath\deployments.yml"
	SaveToYaml -InputObject $SrcLicenses -FilePath "$FolderPath\licenses.yml"
	SaveToYaml -InputObject $SrcRoles -FilePath "$FolderPath\roles.yml"
	SaveToYaml -InputObject $SrcServices -FilePath "$FolderPath\services.yml"
	SaveToYaml -InputObject $SrcSites -FilePath "$FolderPath\sites.yml"
	SaveToYaml -InputObject $SrcVDSwitches -FilePath "$FolderPath\vdswitches.yml"

    # Change commas to ":" Colon for Vlan Network Properties.
	For ($i=0;$i -lt ($SrcVLANS | Measure-Object).count;$i++) {
		$SrcVLANS[$i].psobject.properties | Where-Object {If ($_.name -eq "network") {$commacorrect = $_.value -replace ",",':'; $_.value = $commacorrect}}
	}

	SaveToYaml -InputObject $SrcVLANS -FilePath "$FolderPath\vlans.yml"

    # Change ":" Colon to commas for Vlan Network Properties.
	For ($i=0;$i -lt ($SrcVLANS | Measure-Object).count;$i++) {
		$SrcVLANS[$i].psobject.properties | Where-Object {If ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
	}

    SaveToYaml -InputObject $SrcSummary -FilePath "$FolderPath\summary.yml"
}

ReplaceNull $SrcADInfo
ReplaceNull $SrcPlugins
ReplaceNull $SrcAutoDepRules
ReplaceNull $SrcCertInfo
ReplaceNull $SrcClusters
ReplaceNull $SrcFolders
ReplaceNull $SrcPermissions
ReplaceNull $SrcOSCustomizations
ReplaceNull $SrcDeployments
ReplaceNull $SrcLicenses
ReplaceNull $SrcRoles
ReplaceNull $SrcServices
ReplaceNull $SrcSites
ReplaceNull $SrcVDSwitches
ReplaceNull $SrcVLANS
ReplaceNull $SrcSummary

# ---------------------  END Load Parameters from Excel ------------------------------

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

# Download OpenSSL if it's not already installed
If (!($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"})) {
	$URI = "https://slproweb.com/products/Win32OpenSSL.html"
	$DownloadRef = ((Invoke-WebRequest -uri $URI).Links | Where-Object {$_.outerHTML -like "*Win64OpenSSL_*"} | Select-Object -first 1).href.Split("/")[2]
	Write-Host -Foreground "DarkBlue" -Background "White" "Downloading OpenSSL $DownloadRef ..."
	$null = New-Item -Type Directory $SrcCertInfo[0].openssldir -erroraction silentlycontinue
	$SSLUrl = "http://slproweb.com/download/$DownloadRef"
	$SSLExe = "$env:temp\openssl.exe"
	$WC 							= New-Object System.Net.WebClient
	$WC.UseDefaultCredentials 		= $true
	$WC.DownloadFile($SSLUrl,$SSLExe)
	$env:path = $env:path + ";$($SrcCertInfo[0].openssldir)"
    If (!(test-Path($SSLExe))) { Write-Host -Foreground "red" -Background "white" "Could not download or find OpenSSL. Please install the latest $DownloadRef manually or update download name."; Exit}
	Write-Host -Foreground "DarkBlue" -Background "White" "Installing OpenSSL..."
    cmd /c $SSLExe /DIR="$($SrcCertInfo[0].openssldir)" /silent /verysilent /sp- /suppressmsgboxes
	Remove-Item $SSLExe
}

# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName} | Sort-Object

$OpenSSL = ($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"}).InstallLocation + "bin\openssl.exe"

# Check for openssl
CheckOpenSSL $OpenSSL

Separatorline

# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
$NetAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

If($NetAssembly)
{
    $BindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
    $SettingsType = $NetAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

    $Instance = $SettingsType.InvokeMember("Section", $BindingFlags, $null, $null, @())

    If($Instance)
    {
        $BindingFlags = "NonPublic","Instance"
        $UseUnsafeHeaderParsingField = $SettingsType.GetField("useUnsafeHeaderParsing", $BindingFlags)

        If($UseUnsafeHeaderParsingField)
        {
          $UseUnsafeHeaderParsingField.SetValue($Instance, $true)
        }
    }
}

# Global variables
$PSCDeployments		= @("tiny","small","medium","large","infrastructure")

# Certificate variables
# Create the RANDFILE environmental parameter for openssl to fuction properly.
$env:RANDFILE 		= "$FolderPath\Certs\.rnd"

$Script:CertsWaitingForApproval = $false
New-Alias -Name OpenSSL $OpenSSL

Stop-Transcript

# Deploy the VCSA servers.
ForEach ($Deployment in $SrcDeployments| Where-Object {$_.Action}) {
	# Skip deployment if set to null.

	$OutputPath = "$LogPath\Deploy-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting deployment of $($Deployment.vmName) ===============" | Out-String

	# Deploy the vcsa
	Deploy $Deployment $OvfToolPath $LogPath

	# Write separator line to transcript.
	Separatorline

	# Create esxi credentials.
	$ESXiSecPasswd		= $null
	$ESXiCreds			= $null
	$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

	# Connect to esxi host of the deployed vcsa.
	$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

	Separatorline

	$Script = 'find /var/log/firstboot/ -type f \( -name "succeeded" -o -name "failed" \)'

	Write-Output "== Firstboot process could take 10+ minutes to complete. please wait. ==" | Out-String

	If (!$StopWatch) {
		$StopWatch =  [system.diagnostics.stopwatch]::StartNew()}
	  Else {$StopWatch.start()}

	$Firstboot = (ExecuteScript $Script $Deployment.Hostname "root" $($Deployment.VCSARootPass) $ESXiHandle).ScriptOutput

	While (!$Firstboot) {

	  	Start-Sleep -s 15

	  	$Elapsed = $StopWatch.Elapsed.ToString('hh\:mm\:ss')

		Write-Progress -Activity "Completing Firstboot for $($Deployment.Hostname)" -Status "Time Elapsed $Elapsed"

		Write-Output "Time Elapsed completing Firstboot for $($Deployment.Hostname): $Elapsed" | Out-String

		$Firstboot = (ExecuteScript $Script $Deployment.Hostname "root" $($Deployment.VCSARootPass) $ESXiHandle).ScriptOutput
	}

	$StopWatch.reset()

	If ($Firstboot -like "*failed*") {
		Write-Output "Deployment of " + $Deployment.Hostname + " Failed. Exiting Script." | Out-String
		Break
	}

    # Enable Jumbo Frames on eth0 if True.
    If ($Deployment.JumboFrames) {
        $CommandList = $null
	    $CommandList = @()
		$CommandList += 'echo -e "" >> /etc/systemd/network/10-eth0.network'
		$CommandList += 'echo -e "[Link]" >> /etc/systemd/network/10-eth0.network'
	    $CommandList += 'echo -e "MTUBytes=9000" >> /etc/systemd/network/10-eth0.network'

        ExecuteScript $CommandList $Deployment.vmName "root" $Deployment.VCSARootPass $ESXiHandle
    }

	Write-Output "`r`n The VCSA $($Deployment.Hostname) has been deployed and is available.`r`n" | Out-String

	# Create certificate directory if it does not exist
	$CertDir			= $FolderPath + "\Certs\" + $Deployment.SSODomainName
	$DefaultRootCertDir = $CertDir + "\" + $Deployment.Hostname + "\DefaultRootCert"

	If (!(Test-Path $DefaultRootCertDir)) { New-Item $DefaultRootCertDir -Type Directory | Out-Null }

	Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

	ConfigureCertPairs $CertDir $Deployment $ESXiHandle

    # Import the vCenter self signed certificate into the local trusted root certificate store.
	InstallNodeRootCert $DefaultRootCertDir $Deployment $ESXiHandle

	# Disconnect from the vcsa deployed esxi server.
	DisConnect-VIServer -Server $ESXiHandle -Confirm:$false

	# Write separator line to transcript.
	Separatorline

	Write-Host "=============== End of Deployment for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

# Replace Certificates.
ForEach ($Deployment in $SrcDeployments| Where-Object {$_.Certs}) {

	$OutputPath = "$LogPath\Certs-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	Write-Output "=============== Starting replacement of Certs on $($Deployment.vmName) ===============" | Out-String

	# Wait until the vcsa is available.
	Available $("https://" + $Deployment.Hostname)

	# Set $CertDir
	$CertDir 		= $FolderPath + "\Certs\" + $Deployment.SSODomainName
	$RootCertDir	= $CertDir + "\" + $Deployment.Hostname

	# Create certificate directory if it does not exist
	If (!(Test-Path $RootCertDir)) { New-Item $RootCertDir -Type Directory | Out-Null }

	$SrcCerts = $SrcCertInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}

	Write-Output $SrcCerts | Out-String

	If ($SrcCerts) {
		# Create esxi credentials.
        $ESXiSecPasswd		= $null
		$ESXiCreds			= $null
		$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
		$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

		# Connect to esxi host of the deployed vcsa.
		$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

		# Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
		$SrcCerts.CompanyName = $Deployment.Hostname

		# $InstanceCertDir is the script location plus cert folder and Hostname eg. C:\Script\Certs\SSODomain\vm-host1.companyname.com\
		$InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

		# Check for or download root certificates.
		DownloadRoots $RootCertDir	$SrcCerts

		# Create the Machine cert.
		CreateCSR machine machine_ssl.csr machine_ssl.cfg ssl_key.priv 6 $InstanceCertDir $SrcCerts
		OnlineMint machine machine_ssl.csr new_machine.crt $SrcCerts.V6Template $InstanceCertDir $SrcCerts.IssuingCA
		CreatePEMFiles machine new_machine.crt new_machine.cer $RootCertDir $InstanceCertDir

		# Change back to the script root folder.
		CDDir $FolderPath

		# Create the VMDir cert.
		CreateCSR VMDir VMDir.csr VMDir.cfg VMDir.priv 6 $InstanceCertDir $SrcCerts
		OnlineMint VMDir VMDir.csr VMDir.crt $SrcCerts.V6Template $InstanceCertDir $SrcCerts.IssuingCA
		CreatePEMFiles VMDir VMDir.crt VMdir.cer $RootCertDir $InstanceCertDir

		# Rename the VMDir cert for use on a VMSA.
		VMDirRename $InstanceCertDir

		# Change back to the script root folder.
		CDDir $FolderPath

        $SSOParent = $null
        $SSOParent = $SrcDeployments| Where-Object {$Deployment.Parent -eq $_.Hostname}

		# Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
		If ($Deployment.DeployType -eq "infrastructure" ) {
			CreatePscSolutionCert $RootCertDir $CertDir $InstanceCertDir $SrcCerts
			Separatorline
            # Copy Cert files to vcsa Node and deploy them.
            TransferCerttoNode $RootCertDir $CertDir $Deployment $ESXiHandle $SSOParent
		}
		Else {CreateVCSolutionCert $RootCertDir $CertDir $InstanceCertDir $SrcCerts
			  Separatorline
              # Copy Cert files to vcsa Node and deploy them.
              TransferCerttoNode $RootCertDir $CertDir $Deployment $ESXiHandle $SSOParent

			  # Configure Autodeploy and replace the solution user certificates, and update the thumbprint to the new machine ssl thumbprint.
			  # https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988
              If (($SrcServices | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AutoDeploy"}).Service) {
				  $CommandList = $null
				  $CommandList = @()
				  # Set path for python.
				  $CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $CommandList += "export VMWARE_LOG_DIR=/var/log"
				  $CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
				  $CommandList += "export VMWARE_DATA_DIR=/storage"
				  # Configure Autodeploy to automatic start and start the service.
				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
 				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"
				  # Replace the solution user cert for Autodeploy.
				  $CommandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.Hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				  # Configure imagebuilder and start the service.
				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"
				  # Replace the imagebuilder solution user cert.
				  $CommandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.imagebuilder -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($Deployment.Hostname) -u administrator@$($Deployment.SSODomainName) -p `'$($Deployment.SSOAdminPass)`'"
				  ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle

				  # Get the new machine cert thumbprint.
				  $CommandList = $null
				  $CommandList = @()
				  $CommandList += "openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint"
				  $newthumbprint = $(ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle).Scriptoutput.Split("=",2)[1]
				  $newthumbprint = $newthumbprint -replace "`t|`n|`r",""

				  # Replace the autodeploy cert thumbprint.
				  $CommandList = $null
				  $CommandList = @()
				  # Set path for python.
				  $CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $CommandList += "export VMWARE_LOG_DIR=/var/log"
				  $CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
				  $CommandList += "export VMWARE_DATA_DIR=/storage"
				  # Stop the autodeploy service.
				  $CommandList += "/usr/bin/service-control --stop vmware-rbd-watchdog"
				  # Replace the thumbprint.
				  $CommandList += "autodeploy-register -R -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -s `"/etc/vmware-rbd/autodeploy-setup.xml`" -f -T $newthumbprint"
				  # Start the autodeploy service.
				  $CommandList += "/usr/bin/service-control --start vmware-rbd-watchdog"
				  ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
				}
			  If (($SrcServices | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AuthProxy"}).Service) {
				  # Create Authorization Proxy Server Certificates.
				  CreateCSR authproxy authproxy.csr authproxy.cfg authproxy.priv 6 $InstanceCertDir $SrcCerts
				  OnlineMint authproxy authproxy.csr authproxy.crt $SrcCerts.V6Template $InstanceCertDir $SrcCerts.IssuingCA

				  # Copy the Authorization Proxy Certs to the vCenter.
				  $FileLocations = $null
				  $FileLocations = @()
				  $FileLocations += "$InstanceCertDir\authproxy\authproxy.priv"
				  $FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.key"
				  $FileLocations += "$InstanceCertDir\authproxy\authproxy.crt"
				  $FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.crt"

				  CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle $true

				  # Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
				  $CommandList = $null
				  $CommandList = @()
				  $CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
				  $CommandList += "export VMWARE_LOG_DIR=/var/log"
				  $CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
				  $CommandList += "export VMWARE_DATA_DIR=/storage"
				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
 				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				  $CommandList += "/usr/lib/vmware-vmcam/bin/camregister --unregister -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`'"
				  $CommandList += "/usr/bin/service-control --stop vmcam"
				  $CommandList += "mv /var/lib/vmware/vmcam/ssl/rui.crt /var/lib/vmware/vmcam/ssl/rui.crt.bak"
				  $CommandList += "mv /var/lib/vmware/vmcam/ssl/rui.key /var/lib/vmware/vmcam/ssl/rui.key.bak"
				  $CommandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.crt /var/lib/vmware/vmcam/ssl/rui.crt"
				  $CommandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.key /var/lib/vmware/vmcam/ssl/rui.key"
				  $CommandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.crt"
				  $CommandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.key"
				  $CommandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
				  $CommandList += "/usr/lib/vmware-vmcam/bin/camregister --register -a " + $Deployment.Hostname + " -u Administrator@" + $Deployment.SSODomainName + " -p `'" + $Deployment.SSOAdminPass + "`' -c /var/lib/vmware/vmcam/ssl/rui.crt -k /var/lib/vmware/vmcam/ssl/rui.key"

				  # Service update
				  ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
			    }

        	  }

        Separatorline

        Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

        ConfigureCertPairs $CertDir $Deployment $ESXiHandle

		# Write separator line to transcript.
		Separatorline

		# Delete all certificate files etc to clean up /root/ - exclude authorized_keys
		$CommandList = $null
		$CommandList = @()
		$CommandList += 'rm /root/vcrootcert.crt'
		$CommandList += 'rm -r /root/solutioncerts'
		$CommandList += 'rm -r /root/ssl'
		$CommandList += 'find /root/.ssh/ ! -name "authorized_keys" -type f -exec rm -rf {} \;'

		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle

		Write-Host "=============== Restarting $($Deployment.vmName) ===============" | Out-String
		Restart-VMGuest -VM $Deployment.vmName -Server $ESXiHandle -Confirm:$false

		# Wait until the vcsa is available.
		Available $("https://" + $Deployment.Hostname)

		Write-Host "=============== End of Certificate Replacement for $($Deployment.vmName) ===============" | Out-String

		# Disconnect from the vcsa deployed esxi server.
		DisConnect-VIServer -Server $ESXiHandle -Confirm:$false
	}

	Stop-Transcript
}

# Configure the vcsa.
ForEach ($Deployment in $SrcDeployments| Where-Object {$_.Config}) {

	$OutputPath = "$LogPath\Config-" + $Deployment.Hostname + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
	Start-Transcript -path $OutputPath -append

	# Set $CertDir
	$CertDir 		= $FolderPath + "\Certs\" + $Deployment.SSODomainName
	$RootCertDir	= $CertDir + "\" + $Deployment.Hostname

	# Create certificate directory if it does not exist
	If (!(Test-Path $RootCertDir)) { New-Item $RootCertDir -Type Directory | Out-Null }

	Write-Output "=============== Starting configuration of $($Deployment.vmName) ===============" | Out-String

	Separatorline

	# Wait until the vcsa is available.
	Available $("https://" + $Deployment.Hostname)

	# Create esxi credentials.
    $ESXiSecPasswd		= $null
	$ESXiCreds			= $null
	$ESXiSecPasswd		= ConvertTo-SecureString $Deployment.esxiRootPass -AsPlainText -Force
	$ESXiCreds			= New-Object System.Management.Automation.PSCredential ($Deployment.esxiRootUser, $ESXiSecPasswd)

	# Connect to esxi host of the deployed vcsa.
	$ESXiHandle = Connect-VIServer -server $Deployment.esxiHost -credential $ESXiCreds

	Write-Host "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String

	ConfigureCertPairs $CertDir $Deployment $ESXiHandle

	Separatorline

	Write-Output $($SrcADInfo | Where-Object {$SrcADInfo.vCenter -match "all|$($Deployment.Hostname)"}) | Out-String

    # Join the vcsa to the windows domain.
	JoinADDomain $Deployment $($SrcADInfo | Where-Object {$SrcADInfo.vCenter -match "all|$($Deployment.Hostname)"}) $ESXiHandle

	# if the vcsa is not a stand alone PSC, configure the vCenter.
	If ($Deployment.DeployType -ne "infrastructure" ) {

		Write-Output "== vCenter $($Deployment.vmName) configuration ==" | Out-String

		Separatorline

		$Datacenters	= $SrcSites | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
		$SSOSecPasswd	= ConvertTo-SecureString $($Deployment.SSOAdminPass) -AsPlainText -Force
		$SSOCreds		= New-Object System.Management.Automation.PSCredential ($("Administrator@" + $Deployment.SSODomainName), $SSOSecPasswd)

		# Connect to the vCenter
		$VCHandle = Connect-viserver $Deployment.Hostname -Credential $SSOCreds

		# Create Datacenter
		If ($Datacenters) {
			$Datacenters.Datacenter.ToUpper() | ForEach-Object {New-Datacenter -Location Datacenters -Name $_}
		}

		# Create Folders, Roles, and Permissions.
		$Folders = $SrcFolders | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
		If ($Folders) {
			Write-Output "Folders:" $Folders
			CreateFolders $Folders $VCHandle
		}

		# if this is the first vCenter, create custom Roles.
		$existingroles = Get-VIRole -Server $VCHandle
		$Roles = $SrcRoles | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"} | Where-Object {$ExistingRoles -notcontains $_.Name}
           If ($Roles) {
			Write-Output  "Roles:" $Roles
			CreateRoles $Roles $VCHandle
		}

		# Create OS Customizations for the vCenter.
		$SrcOSCustomizations | Where-Object {$_.vCenter -eq $Deployment.Hostname} | ForEach-Object {OSString $_}

		# Create Clusters
		ForEach ($Datacenter in $Datacenters) {
			# Define IP Octets
			$Oct1 = $Datacenter.oct1
			$Oct2 = $Datacenter.oct2
			$Oct3 = $Datacenter.oct3

			# Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
               ($SrcClusters | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)")`
                   -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}).Clustername |`
				ForEach-Object {If ($_) {New-Cluster -Location (Get-Datacenter -Server $VCHandle -Name $Datacenter.Datacenter) -Name $_}}

			# Create New vDSwitch
			# Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
			$VDSwitches = $SrcVDSwitches | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}

			ForEach ($VDSwitch in $VDSwitches) {
				$SwitchDatacenter	= Get-Inventory -Name $Datacenter.Datacenter

				If ($VDSwitch.SwitchNumber.ToString().indexof(".") -eq -1) {
					$SwitchNumber = $VDSwitch.SwitchNumber.ToString() + ".0"}
				Else { $SwitchNumber = $VDSwitch.SwitchNumber.ToString()}

				$SwitchName = $SwitchNumber + " " + $VDSwitch.vDSwitchName -replace "XXX", $Datacenter.Datacenter

                If ($VDSwitch.JumboFrames) {$mtu = 9000} Else {
                    $mtu = 1500
                }

				# Create new vdswitch.
				New-VDSwitch -Server $VCHandle -Name $SwitchName -Location $SwitchDatacenter -Mtu $mtu -NumUplinkPorts 2 -Version $VDSwitch.Version

				# Enable NIOC
				(Get-vDSwitch -Server $VCHandle -Name $SwitchName | Get-View).EnableNetworkResourceManagement($true)

				$VLANAdd = $SrcVLANS | Where-Object {$_.Number.StartsWith($SwitchName.Split(" ")[0])}
				$VLANAdd = $VLANAdd	 | Where-Object {$_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)"}
				$VLANAdd = $VLANAdd  | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

				# Create Portgroups
				ForEach ($VLAN in $VLANAdd) {

					$PortGroup =	$VLAN.Number.padright(8," ") +`
									$VLAN.Vlan.padright(8," ") + "- " +`
									$VLAN.Network.padright(19," ") + "- " +`
									$VLAN.VlanName

					$PortGroup = $PortGroup -replace "oct1", $Oct1
					$PortGroup = $PortGroup -replace "oct2", $Oct2
					$PortGroup = $PortGroup -replace "oct2", $Oct3

                       If ($PortGroup.Split("-")[0] -like "*trunk*") {
                           New-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.Split("-")[0] -VlanTrunkRange $VLAN.network
                       }
                       Else {
					    New-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName -Name $PortGroup -Notes $PortGroup.Split("-")[0] -VlanId $VLAN.vlan.Split(" ")[1]
                       }
					# Set Portgroup Team policies
					If ($PortGroup -like "*vmotion-1*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
					}
					If ($PortGroup -like "*vmotion-2*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
					}
					If ($PortGroup -notlike "*vmotion*") {
						Get-vdportgroup -Server $VCHandle | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $VCHandle | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
					}
					Else
					{
					#Set Traffic Shaping on vmotion portgroups for egress traffic
					Get-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName | Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | Get-VDTrafficShapingPolicy -Server $VCHandle -Direction Out| Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
					}
				}
			}
		}

		# Add Licenses to vCenter.
		If ($SrcLicenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) { ConfigureLicensing $($SrcLicenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $VCHandle}

		# Select permissions for all vCenters or the current vCenter.
		# Create the permissions.
		CreatePermissions $($SrcPermissions | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}) $VCHandle

		$InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

		# Configure Additional Services (Network Dump, Autodeploy, TFTP)
		ForEach ($Serv in $SrcServices) {
			Write-Output $Serv | Out-String
			If ($Serv.vCenter.Split(",") -match "all|$($Deployment.Hostname)") {
				Switch ($Serv.Service) {
					AuthProxy	{ ConfigureAuthProxy $Deployment $ESXiHandle $($SrcADInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}); Break}
					AutoDeploy	{ $VCHandle | get-advancedsetting -Name vpxd.certmgmt.certs.minutesBefore | Set-AdvancedSetting -Value 1 -Confirm:$false
								  ConfigureAutoDeploy $Deployment $ESXiHandle
								  If ($SrcAutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) { ConfigureAutoDeployRules $($SrcAutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) $FolderPath $VCHandle}
								  ; Break
					}
					Netdumpster	{ ConfigureNetdumpster $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle; Break}
					TFTP		{ ConfigureTFTP $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle; Break}
					default {Break}
				}
			}
		}

        # Configure plugins
        $CommandList = $null
        $CommandList = @()
        $Plugins = $SrcPlugins | Where-Object {$_.config -and $_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

		Separatorline
		Write-Output $Plugins | Out-String
		Separatorline

           For ($i=0;$i -lt $Plugins.Count;$i++) {
               If ($Plugins[$i].SourceDir) {
                   If ($CommandList) {
                       ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
                       $CommandList = $null
                       $CommandList = @()
                   }

                   $FileLocations = $null
                   $FileLocations = @()
	               $FileLocations += "$($FolderPath)\$($Plugins[$i].SourceDir)\$($Plugins[$i].SourceFiles)"
                   $FileLocations += $Plugins[$i].DestDir

				Write-Output $FileLocations | Out-String

       	        CopyFiletoServer $FileLocations $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle $true
               }

               If ($Plugins[$i].Command) {$CommandList += $Plugins[$i].Command}
           }

           If ($CommandList) {ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle}

		Separatorline

		# Disconnect from the vCenter.
		DisConnect-VIServer -server $VCHandle -Confirm:$false

		Separatorline

	}

	# Run the vami_set_Hostname to set the correct FQDN in the /etc/hosts file on a vCenter with External PSC only.
	If ($Deployment.DeployType -like "*management*") {
		$CommandList = $null
		$CommandList = @()
		$CommandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
		$CommandList += "export VMWARE_LOG_DIR=/var/log"
		$CommandList += "export VMWARE_CFG_DIR=/etc/vmware"
		$CommandList += "export VMWARE_DATA_DIR=/storage"
		$CommandList += "/opt/vmware/share/vami/vami_set_hostname $($Deployment.Hostname)"

		ExecuteScript $CommandList $Deployment.Hostname "root" $Deployment.VCSARootPass $ESXiHandle
       }

	# Disconnect from the vcsa deployed esxi server.
	DisConnect-VIServer -Server $ESXiHandle -Confirm:$false

	Separatorline

	Write-Host "=============== End of Configuration for $($Deployment.vmName) ===============" | Out-String

	Stop-Transcript
}

Separatorline

Write-Output "<=============== Deployment Complete ===============>" | Out-String

Set-Location -Path $FolderPath

# Get Certificate folders that do not have a Date/Time in their name.
$CertFolders = (Get-Childitem -Path $($FolderPath + "\Certs") -Directory).FullName | Where-Object {$_ -notmatch '\d\d-\d\d-\d\d\d\d'}

# Rename the folders to add Date/Time to the name.
$CertFolders | ForEach-Object {
	Rename-Item -Path $_ -NewName $($_ + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm"))
}

# Scrub logfiles
$LogFiles = (Get-ChildItem -Path $LogPath).FullName

If ($SrcSummary.TranscriptScrub) {
    ForEach ($Log in $LogFiles) {
        $Transcript = Get-Content -path $Log
	    ForEach ($Pass in $Scrub) {
		    $Transcript = $Transcript.replace($Pass,'<-- Password Redacted -->')}
    	$Transcript | Set-Content -path $Log -force -confirm:$false
    }
}
