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
	  
	To be done:
	1. Resolve correctly closing Excel so that it does not stay in memory.
	2. Reconfigure vdswitch creation for full flexibility.
	3. Test and add functionality for multi part certificate replacement.
	4. Create certificates for Load Balancers.
	5. Test VMCA certificate deployment.
	6. Test various other configurations of deployment.
	7. Add prompt for credentials instead of reading from Excel.
	8. Add fuctionality for installing the licenses.
   
.PARAMETER
   None.
.EXAMPLE
   <An example of using the script>
.REQUIREMENTS
	Programs:
		1. OpenSSL 1.0.2h x64 - C:\OpenSSL-Win64
		2. Ovftool 4.0.1
		3. Excel 2010+
		4. Powershell 3+
		5. PowerCli 5.8+
		
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
	12. Féidhlim O'Leary		- haveyoutriedreinstalling.com
	13. Alan Renouf				- www.virtu-al.net
	13. Jeramiah Dooley			- Netapp
	14. Aaron Patten			- Netapp
	15. VMWare Support
	16. John Dwyer				- grokthecloud.com
	17.	Rob Bastiaansen 		- www.vmwarebits.com
	
Functions start at line 139
Main program starts at line 1000
	
.AUTHOR
	Michael van Blijdesteijn - Highbridge Capital Management LLC.
	michael.vanblijdestein@highbridge.com
#>

# Clear the screen.
cls

<# Functions Lines 96 - 845
List:							Used:	function Dependency:
1.  Available					  Y
2. 	ConfigureAutoDeploy			  Y		ExecuteScript
3. 	ConfigureIdentity			  Y		ExecuteScript
4. 	ConfigureNetdumpster		  Y		ExecuteScript
5. 	ConfigureTFTP				  Y		ExecuteScript
6.  Deploy						  Y
7.  CreateFolders				  Y		Separatorline
8.  CreateRoles					  Y		Separatorline
9.  CreatePermissions			  Y		Separatorline
10. ExecuteScript				  Y		Separatorline
11. CopyFiletoServer			  Y		Separatorline
12. Separatorline				  Y
13. ChainCAs					  Y
14. CheckOpenSSL				  Y
15. CreatePEMFiles				  Y
16. CreateCSR					  Y
17. CreateSolutionCSR			  Y
18. CreateVMCACSR				  Y
19. DisplayVMDir				  Y
20. DownloadRoots				  Y
21. MoveUserCerts				  Y
22. OnlineMint					  Y
23. OnlineMintResume			  N
24. TransferCertToNode			  Y		ExecuteScript, CopyFiletoServer
25. UserPEMFiles				  Y		CreatePEMFiles
26. VMCAMint					  N
27. CDDir						  Y
28. CreateVCSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles
29. CreatePscSolutionCert		  Y		CreateSolutionCSR, OnlineMint, CreatePEMFiles


#>

# Check to see if the url is available.
function Available ($url) {
	$error.clear()
	$output = $null
	
	write-host "`r`n Waiting on $url to resolve.`r`n" -foregroundcolor yellow
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
function ConfigureAutoDeploy ($IP,$hostname,$username,$password,$domain) {
	$commandlist = $null
	$commandlist = @()
	
	$commandlist += "/usr/bin/autodeploy-register -R -a $($IP) -u administrator@$($domain) -w `'$password`' -p 80"
	$commandlist += "/sbin/chkconfig vmware-rbd-watchdog on"
	$commandlist += "/etc/init.d/vmware-rbd-watchdog start"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.crt"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getkey --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.key"
	$commandlist += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
	$commandlist += 'export VMWARE_LOG_DIR=/var/log'
	$commandlist += 'export VMWARE_CFG_DIR=/etc/vmware'
	$commandlist += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s localhost -u administrator@$($domain) -p `'$password`'"
	
	#Service update
	ExecuteScript $commandlist $hostname $username $password
}

# Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.
function ConfigureIdentity ($domain,$vcsa_fqdn,$vcsa_root_password,$ad_domain,$ad_group) {
			$sub_domain		= $domain.split(".")[0]
			$domain_ext		= $domain.split(".")[1]
			$commandlist 	= $null
			$commandlist 	= @()
			
			# Active Directory variables
			$AD_admins_group_sid	= (Get-ADgroup -Identity $ad_group).sid.value
			
			# Add AD domain as Native Identity Source
			$commandlist += "/usr/lib/vmidentity/tools/scripts/sso-add-native-ad-idp.sh $ad_domain"
			
			# Set Default SSO Identity Source Domain
			$commandlist += "echo -e `"dn: cn=$domain,cn=Tenants,cn=IdentityManager,cn=Services,dc=$sub_domain,dc=$domain_ext`" >> defaultdomain.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> defaultdomain.ldif"
			$commandlist += "echo -e `"replace: vmwSTSDefaultIdentityProvider`" >> defaultdomain.ldif"
			$commandlist += "echo -e `"vmwSTSDefaultIdentityProvider: $ad_domain`" >> defaultdomain.ldif"
			$commandlist += "echo -e `"-`" >> defaultdomain.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/defaultdomain.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to Component Administrators SSO Group.
			$commandlist += "echo -e `"dn: cn=ComponentManager.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_cma.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_cma.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_cma.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_cma.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_cma.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_cma.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to License Administrators SSO Group.
			$commandlist += "echo -e `"dn: cn=LicenseService.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_la.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_la.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_la.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_la.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_la.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_la.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to Administrators SSO Group.
			$commandlist += "echo -e `"dn: cn=Administrators,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_adm.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_adm.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_adm.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_adm.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_adm.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_adm.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to Certificate Authority Administrators SSO Group.
			$commandlist += "echo -e `"dn: cn=CAAdmins,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_caa.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_caa.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_caa.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_caa.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_caa.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_caa.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to Users SSO Group.
			$commandlist += "echo -e `"dn: cn=Users,cn=Builtin,dc=$sub_domain,dc=$domain_ext`" >> groupadd_usr.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_usr.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_usr.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_usr.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_usr.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_usr.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Add AD vCenter Admins to System Configuration Administrators SSO Group.
			$commandlist += "echo -e `"dn: cn=SystemConfiguration.Administrators,dc=$sub_domain,dc=$domain_ext`" >> groupadd_sca.ldif"
			$commandlist += "echo -e `"changetype: modify`" >> groupadd_sca.ldif"
			$commandlist += "echo -e `"add: member`" >> groupadd_sca.ldif"
			$commandlist += "echo -e `"member: externalObjectId=$AD_admins_group_sid`" >> groupadd_sca.ldif"
			$commandlist += "echo -e `"-`" >> groupadd_sca.ldif"
			$commandlist += "/opt/likewise/bin/ldapmodify -f /root/groupadd_sca.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=$sub_domain,dc=$domain_ext`" -w `'$vcsa_root_password`'"
			
			# Excute the commands in $commandlist on the vcsa.
			ExecuteScript $commandlist $vcsa_fqdn "root" $vcsa_root_password
}

# Configure Network Dumpster to Auto Start and start service.
function ConfigureNetdumpster ($hostname,$username,$password) {
	$commandlist = $null
	$commandlist = @()

	$commandlist += "/sbin/chkconfig vmware-netdumper on"
	$commandlist += "/etc/init.d/vmware-netdumper start"
	
	#Service update
	ExecuteScript $commandlist $hostname $username $password
}

# Configure TFTP, set firewall exemption, set service to auto start, start service.
function ConfigureTFTP ($hostname,$username,$password) {
	$fw_rule = '
{
  	"firewall": {
    	"enable": true,
    	"rules": [
      	{
        	"direction": "inbound",
        	"protocol": "tcp",
        	"porttype": "dst",
        	"port": "69",
        	"portoffset": 0
      	},
      {
        	"direction": "inbound",
        	"protocol": "udp",
        	"porttype": "dst",
        	"port": "69",
        	"portoffset": 0
      }
    ]
  }
}'

	$fw_command = $null
	$fw_command = @()
	
	$fw_command += "echo -e `'$fw_rule`' >> /etc/vmware/appliance/firewall/tftp"
	Invoke-VMScript -ScriptText $($fw_command) -vm $hostname -GuestUser $username -GuestPassword $password | Select -ExpandProperty ScriptOutput	
	
	$commandlist = $null
	$commandlist = @()
	
	$commandlist += "/sbin/chkconfig atftpd on"
	$commandlist += "/etc/init.d/atftpd start"

	$commandlist += "/usr/lib/applmgmt/networking/bin/firewall-reload"

	#Service update
	ExecuteScript $commandlist $hostname $username $password
}
				
# Deploy a VCSA.
function Deploy ([string[]]$parameterlist, $ovftoolpath) {
	$pscs			= @("tiny","small","large","infrastructure")

	$argumentlist	= @()
	$ovftool		= "$ovftoolpath\ovftool.exe"
	
	if ($parameterlist[0] -ine "--version") {
		$argumentlist += "--X:logFile=upload.log"
		$argumentlist += "--X:logLevel=verbose"
		$argumentlist += "--acceptAllEulas"
		$argumentlist += "--skipManifestCheck"
		$argumentlist += "--noSSLVerify"
		$argumentlist += "--X:injectOvfEnv"
		$argumentlist += "--allowExtraConfig"
		$argumentlist += "--X:enableHiddenProperties"
		$argumentlist += "--X:waitForIp"
		$argumentlist += "--sourceType=OVA"
		$argumentlist += "--powerOn"
		$argumentlist += "--net:Network 1=$($parameterlist[15])"
		$argumentlist += "--datastore=$($parameterlist[16])"
		$argumentlist += "--diskMode=$($parameterlist[12])"
		$argumentlist += "--name=$($parameterlist[1])"
		$argumentlist += "--deploymentOption=$($parameterlist[13])"
		if ($parameterlist[13] -inotlike "*infrastructure*") {
			$argumentlist += "--prop:guestinfo.cis.system.vm0.hostname=$($parameterlist[19])"}
		$argumentlist += "--prop:guestinfo.cis.vmdir.domain-name=$($parameterlist[20])"
		$argumentlist += "--prop:guestinfo.cis.vmdir.site-name=$($parameterlist[21])"
		$argumentlist += "--prop:guestinfo.cis.vmdir.password=$($parameterlist[22])"
		if ($parameterlist[0] -ine "first" -and $pscs -contains $parameterlist[13]) {
			$argumentlist += "--prop:guestinfo.cis.vmdir.first-instance=False"
			$argumentlist += "--prop:guestinfo.cis.vmdir.replication-partner-hostname=$($parameterlist[19])"}
		$argumentlist += "--prop:guestinfo.cis.appliance.net.addr.family=$($parameterlist[5])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.addr=$($parameterlist[7])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.pnid=$($parameterlist[2])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.prefix=$($parameterlist[6])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.mode=$($parameterlist[4])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.dns.servers=$($parameterlist[9])"
		$argumentlist += "--prop:guestinfo.cis.appliance.net.gateway=$($parameterlist[8])"
		$argumentlist += "--prop:guestinfo.cis.appliance.root.passwd=$($parameterlist[3])"
		$argumentlist += "--prop:guestinfo.cis.appliance.ssh.enabled=$($parameterlist[11])"
		$argumentlist += "--prop:guestinfo.cis.appliance.ntp.servers=$($parameterlist[10])"
		$argumentlist += "$ova"
		$argumentlist += "vi://$($parameterlist[17])`:$($parameterlist[18])@$($parameterlist[14])"
	}
	
	echo $argumentlist
	
	return & $ovftool $argumentlist	
}

#Create Folders
function CreateFolders ($folders, $vc) {
	Separatorline
	
foreach ($folder in $folders) {
	write-host $folder.Name
	foreach ($datacenter in get-datacenter -Server $vc) {
		if ($folder.datacenter -ieq "all" -or $datacenter.name -ieq $folder.datacenter) {	
			$location = $datacenter | get-folder -name $folder.Location | ?{$_.Parentid -inotlike "*ha*"}
			write-host $location
			New-Folder -Server $vc -Name $folder.Name -Location $location -Confirm:$false
		}
	}	
}
	   
	Separatorline
}

#Create Roles
function CreateRoles ($Roles, $vc) {
	Separatorline

	$Names = $Roles | Select Name -Unique
	foreach ($Name in $Names) {
		$vPrivilege = $Roles | ?{$_.Name -ilike $Name.Name} | Select Privilege
		
		echo $vPrivilege
		
		New-VIRole -Server $vc -Name $Name.Name -Privilege (Get-VIPrivilege -Server $vc | ?{$vPrivilege.Privilege -ilike $_.id})
	}

	Separatorline
}

#Set Permissions
function CreatePermissions ($vPermissions, $vc) {
	Separatorline
	
	foreach ($Permission in $vPermissions) {
		$Entity = Get-Inventory -Name $Permission.Entity
		New-VIPermission -Server $vc -Entity $Entity -Principal $Permission.Principal -Role $Permission.Role -Propagate $([System.Convert]::ToBoolean($Permission.Propagate))
		
	}
		
	echo $vPermissions
	
	Separatorline
}

# Execute a script via Invoke-VMScript.
function ExecuteScript ($script,$hostname,$username,$password) {

	Separatorline
	
	echo $script
	
	Separatorline
	
	Invoke-VMScript -ScriptText $(if ($script.count -gt 1) {$script -join(";")} else {$script}) -vm $hostname -GuestUser $username -GuestPassword $password | Select -ExpandProperty ScriptOutput
	
	Separatorline
}

# Copy a file to a VM.
function CopyFiletoServer ($locations,$hostname,$username,$password) {
	
	Separatorline
	
	for ($i=0; $i -le ($locations.count/2)-1;$i++) {
		write-host "Sources: `n"
		echo $locations[$i*2]
		write-host "Destinations: `n"
		echo $locations[($i*2)+1]
		Copy-VMGuestFile -VM $hostname -LocalToGuest -Source $($locations[$i*2]) -Destination $($locations[($i*2)+1]) -guestuser $username -GuestPassword $password -force
	}

	Separatorline
}

# Print a dated line to standard output.
function Separatorline {
	$date = Get-Date
	Write-Host "`n---------------------------- $date ----------------------------`r`n" -foregroundcolor white
}

#
# Certificate functions
#

function ChainCAs ($Cert_Dir,$rootcer,$intermcer,$interm2cer) {
# Chains CA files together in a PEM encoded file. Supports root CA and two subordinates.
# Skip if we have pending cert requests
	if ($Script:CertsWaitingForApproval) {return}
	# Prompt for Root cert if it's not there yet
	if (Test-Path $intermcer) {
		cmd /c copy $intermcer+$rootcer $Cert_Dir\chain.cer
	}
	if (Test-Path $interm2cer) {
		cmd /c copy $interm2cer+$intermcer+$rootcer $Cert_Dir\chain.cer
	}
}

function CheckOpenSSL ($openssl) {
   if (!(Test-Path $openssl)) {throw "Openssl required, unable to download, please install manually. Use latest OpenSSL 1.0.2."; Exit}
}

function CreatePEMFiles ($SVCDir, $CertFile, $CerFile, $Cert_Dir, $InstanceCertDir) {
	# Create PEM file for supplied certificate
	# Skip if we have pending cert requests
	if ($Script:CertsWaitingForApproval) {return;}
	if (Test-Path $Cert_Dir\chain.cer) {$chaincer = "$Cert_Dir\chain.cer"}
	else {$chaincer = "$Cert_Dir\root64.cer"}
	
	if (!(test-path $InstanceCertDir\$SVCDir\$CertFile)) {
		Write-host "$InstanceCertDir\$SVCDir\$CertFile file not found. Skipping PEM creation. Please correct and re-run." -ForegroundColor Red
	}
	else {$RUI = get-content $InstanceCertDir\$SVCDir\$CertFile
		  $ChainCont = get-content $chaincer -encoding default
		  $RUI + $ChainCont | out-file  $InstanceCertDir\$SVCDir\$CerFile -Encoding default
		  Write-host "PEM file $InstanceCertDir\$SVCDir\$CerFile succesfully created" -ForegroundColor Yellow
	}
	Set-Location $Cert_Dir	
}

#
# CSR Functions
#

function CreateCSR ($SVCDir, $CSRName, $CFGName, $PrivFile, $Flag, $Cert_Dir, $Certinfo) {
# Create RSA private key and CSR for vSphere 6.0 SSL templates
	if (!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	#vSphere 5 and 6 CSR Options are different. Set according to flag type
	#VUM 6.0 needs vSphere 5 template type
	if ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	if ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo[0] 
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo[0]
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
	countryName = $($Certinfo[5])
	stateOrProvinceName = $($Certinfo[3])
	localityName = $($Certinfo[4])
	0.organizationName = $($Certinfo[1])
	organizationalUnitName = $($Certinfo[2])
	commonName = $CommonName
	"
	Set-Location $Cert_Dir
    if (!(Test-Path $SVCDir)) {new-Item Machine -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$Cert_Dir\$SVCDir\$CFGName" -Encoding Default -Force 
    OpenSSL req -new -nodes -out "$Cert_Dir\$SVCDir\$CSRName" -keyout "$Cert_Dir\$SVCDir\machine-org.key" -config  "$Cert_Dir\$SVCDir\$CFGName"
    OpenSSL rsa -in "$Cert_Dir\$SVCDir\machine-org.key" -out "$Cert_Dir\$SVCDir\$PrivFile"
    Remove-Item $SVCDir\machine-org.key
    write-host "CSR is located at $Cert_Dir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateSolutionCSR ($SVCDir, $CSRName, $CFGName, $PrivFile, $Flag, $SolutionUser, $Cert_Dir, $Certinfo) {
# Create RSA private key and CSR for vSphere 6.0 SSL templates
	if (!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	#vSphere 5 and 6 CSR Options are different. Set according to flag type
	#VUM 6.0 needs vSphere 5 template type
	$CommonName = $CSRName.Split(".")[0] + " " + $Certinfo[0]
	if ($Flag -eq 5) {$CSROption1 = "dataEncipherment"}
	if ($Flag -eq 6) {$CSROption1 = "nonRepudiation"}
	$DEFFQDN = $Certinfo[0] 
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
	countryName = $($Certinfo[5])
	stateOrProvinceName = $($Certinfo[3])
	localityName = $($Certinfo[4])
	0.organizationName = $($Certinfo[1])
	organizationalUnitName = $($Certinfo[2])
	commonName = $CommonName
	"
	Set-Location $Cert_Dir
	if (!(Test-Path $SVCDir)) { new-Item Machine -Type Directory }
	# Create CSR and private key
	$Out = $RequestTemplate | Out-File "$Cert_Dir\$SVCDir\$CFGName" -Encoding Default -Force 
	OpenSSL req -new -nodes -out "$Cert_Dir\$SVCDir\$CSRName" -keyout "$Cert_Dir\$SVCDir\machine-org.key" -config  "$Cert_Dir\$SVCDir\$CFGName"
	OpenSSL rsa -in "$Cert_Dir\$SVCDir\machine-org.key" -out "$Cert_Dir\$SVCDir\$PrivFile"
	Remove-Item $SVCDir\machine-org.key
    write-host "CSR is located at $Cert_Dir\$SVCDir\$CSRName" -ForegroundColor Yellow
}

function CreateVMCACSR {
# Create RSA private key and CSR
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$VPSCFQDN = $(
		Write-Host "Is the vCenter Platform Services Controller FQDN $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new PSC FQDN"
		if ($inputFQDN) {$inputFQDN} else {$DEFFQDN}
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
    if (!(Test-Path VMCA)) {new-Item VMCA -Type Directory}
	# Create CSR and private key
    $Out = $RequestTemplate | Out-File "$Cert_Dir\VMCA\root_signing_cert.cfg" -Encoding Default -Force
    OpenSSL req -new -nodes -out "$Cert_Dir\VMCA\root_signing_cert.csr" -keyout "$Cert_Dir\VMCA\vmca-org.key" -config "$Cert_Dir\VMCA\root_signing_cert.cfg"
    OpenSSL rsa -in "$Cert_Dir\VMCA\vmca-org.key" -out "$Cert_Dir\VMCA\root_signing_cert.key"
    Remove-Item VMCA\vmca-org.key
    write-host "CSR is located at $Cert_Dir\VMCA\root_signing_cert.csr" -ForegroundColor Yellow
}

function DisplayVMDir {
	# Displays the currently used VMDir certificate via OpenSSL
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$VMDirHost = $(
		Write-Host "Do you want to dispaly the VMDir SSL certificate of $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		if ($InputFQDN) {$InputFQDN} else {$DEFFQDN})
	openssl s_client -servername $VMDirHost -connect "${VMDirHost}:636"
}

function DownloadRoots ($Cert_Dir,$RootCA,$rootcer,$SubCA,$intermcer,$SubCA2,$interm2cer,$CADownload) {
# Download Root CA public certificate, if defined
# if the certificate exists (root64.cer) then it won't attempt to download
	if ($RootCA) {
		if (!(test-path -Path $rootcer)) {
			write-host "Downloading root certificate from $rootca ..."
			$url = "$CADownload"+"://$rootCA/certsrv/certnew.cer?ReqID=CACert&$RootRenewal&Enc=b64"
			$wc.DownloadFile($url,$rootcer)
			if (!(test-path -Path $rootcer)) {
				write-host "Root64.cer did not download. Check root CA variable, CA web services, or manually download root cert and copy to $Cert_Dir\root64.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;exit}
			Write-host "Root CA download successful." -foregroundcolor yellow
		}
		else {Write-host "Root CA file found, will not download." -ForegroundColor yellow} 
	}
	$Validation = select-string -simple CERTIFICATE----- $rootcer
	if (!$Validation) {
		write-host "Invalid Root certificate format. Validate BASE64 encoding and try again. Also try decrementing RootRenewal value by 1." -foregroundcolor red; exit}
	# Download Subordinate CA public certificate, if defined
	# if the certificate exists (interm64.cer) then it won't attempt to download
	if ($SubCA) {
		if (!(test-path -Path $intermcer)) {
			write-host "Downloading subordinate certificate from $subca ..."
			$url = "$CADownload"+"://$SubCA/certsrv/certnew.cer?ReqID=CACert&$SubRenewal&Enc=b64"
			$wc.DownloadFile($url,$intermcer)
			if (!(test-path -Path $intermcer)) {
				write-host "Interm64.cer did not download. Check subordinate variable, CA web services, or manually download intermediate cert and copy to $Cert_Dir\interm64.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;exit}
			Write-host "Intermediate CA download successful." -foregroundcolor yellow
		}
		else { Write-host "Intermediate CA file found, will not download." -ForegroundColor yellow} 
		
		$Validation = select-string -simple CERTIFICATE----- $intermcer
		if (!$Validation) {
			write-host "Invalid subordinate certificate format. Validate BASE64 encoding and try again. Also try decrementing SubRenewal value by 1." -foregroundcolor red; exit}
	}
	# Download second-level Subordinate CA public certificate, if defined
	# if the certificate exists (interm264.cer) then it won't attempt to download
	if ($SubCA2) {
		if (!(test-path -Path $interm2cer)) {
			write-host "Downloading second subordinate certificate from $subca2 ..."
			$url = "$CADownload"+"://$SubCA2/certsrv/certnew.cer?ReqID=CACert&$Sub2Renewal&Enc=b64"
			$wc.DownloadFile($url,$interm2cer)
			if (!(test-path -Path $interm2cer)) {
				write-host "Interm264.cer did not download. Check subordinate 2 CA variable, CA web services, or manually download intermediate cert and copy to $Cert_Dir\interm264.cer. See vExpert.me/Derek60 Part 8 for more details." -foregroundcolor red;exit}
			Write-host "Second Intermediate CA download successful." -foregroundcolor yellow
		}
		else { Write-host "Second Intermediate CA file found, will not download." -ForegroundColor yellow} 
		
		$Validation = select-string -simple CERTIFICATE----- $intermcer
		if (!$Validation) {
			write-host "Invalid second subordinate certificate format. Validate BASE64 encoding and try again. Also try decrementing Sub2Renewal value by 1." -foregroundcolor red; exit}
	}
}

function MoveUserCerts {
	Get-ChildItem -Path $Cert_Dir -filter "*.crt" | foreach {
		$Dir = $_.basename
		if (!(Test-Path $Cert_Dir\$Dir)) {New-Item $Cert_Dir\$Dir -Type Directory}
		move-Item -Path $_.FullName -Destination $Cert_Dir\$Dir -Force
	}
	Get-ChildItem -Path $Cert_Dir -filter "*.key" | foreach {
		$Dir = $_.basename
		move-Item -Path $_.FullName -Destination $Cert_Dir\$Dir -Force
	}
}

function OnlineMint ($SVCDir, $CSRFile, $CertFile, $Template, $Cert_Dir, $ISSUING_CA) { 
#Mint certificates from online Microsoft CA
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
    write-host ""
        write-host "Submitting certificate request for $SVCDir..." -ForegroundColor Yellow
        [void]$process.Start()
        $cmdOut = $process.StandardOutput.ReadToEnd()
        if ($cmdOut.Trim() -like "*request is pending*")
        {
            # Output indicates the request requires approval before we can download the signed cert.
            $Script:CertsWaitingForApproval = $true
            # So we need to save the request ID to use later once they're approved.
            $reqID = ([regex]"RequestId: (\d+)").Match($cmdOut).Groups[1].Value
            if ($reqID.Trim() -eq [String]::Empty)
            {
                write-error "Unable to parse RequestId from output."
                write-debug $cmdOut
                Exit
            }
            write-host "RequestId: $reqID is pending" -ForegroundColor Yellow
            # Save the request ID to a file that OnlineMintResume can read back in later
            $reqID | out-file "$Cert_Dir\$SVCDir\requestid.txt"
        }
        else
        {
            # Output doesn't indicate a pending request, so check for a signed cert file
            if (!(Test-Path $Cert_Dir\$SVCDir\$CertFile)) {
                Write-Error "Certificate request failed or was unable to download the signed certificate."
                Write-Error "Verify that the ISSUING_CA variable is set correctly." 
                Write-Debug $cmdOut
                Exit
            }
            else { Write-Host "Certificate successfully downloaded." -ForegroundColor Yellow}
        }
    if ($Script:CertsWaitingForApproval) {
        write-host
        write-host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-host "Contact your CA administrator to approve the request ID(s) listed above." -ForegroundColor Yellow
        write-host "To resume use the appropriate option from the menu." -ForegroundColor Yellow
    }
}

function OnlineMintResume ($SVCDir, $CertFile) {
#Resume the minting process for certificates from online Microsoft CA that required approval
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
    if (!(Test-Path "$Cert_Dir\$SVCDir\requestid.txt")) {continue}
    $reqID = Get-Content "$Cert_Dir\$SVCDir\requestid.txt"
    write-verbose "Found RequestId: $reqID for $SVCDir"
    # retrieve the signed certificate
    $psi.FileName = "certreq.exe"
    $psi.Arguments = @("-retrieve -f -config `"$ISSUING_CA`" $reqID `"$Cert_Dir\$SVCDir\$CertFile`"")
    write-host "Downloading the signed $SVCDir certificate..." -ForegroundColor Yellow
    [void]$process.Start()
    $cmdOut = $process.StandardOutput.ReadToEnd()
    if (!(test-path "$Cert_Dir\$SVCDir\$CertFile")) {
        # it's not there, so check if the request is still pending
        if ($cmdOut.Trim() -like "*request is pending*") {
            $Script:CertsWaitingForApproval = $true
            write-host "RequestId: $reqID is pending" -ForegroundColor Yellow
        }
        else
        {
			write-warning "There was a problem downloading the signed certificate" -foregroundcolor red
			write-warning $cmdOut
			continue
        }
    }
    if ($Script:CertsWaitingForApproval) {
        write-host
        write-host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-host "Contact your CA administrator to approve the request IDs listed above." -ForegroundColor Yellow
    }
    $Script:CertsWaitingForApproval = $false
}

function TransferCertToNode ($Cert_Dir,$servertype,$hostname,$username,$password) {
# http://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.security.doc/GUID-BD70615E-BCAA-4906-8E13-67D0DBF715E4.html
# Copy SSL certificates to a VCSA and replace the existing ones.

	$date 		 = get-date
	
	$certpath 		= "$Cert_Dir\$hostname"
	$SslPath		= "/root/ssl"
	$SolutionPath	= "/root/solutioncerts"
	$script 		= "mkdir $SslPath;mkdir $SolutionPath"
	$pscdeployments	= @("tiny","small","large","infrastructure")
	
	ExecuteScript $script $hostname $username $password

	$filelocations = $null
	$filelocations = @()
	$filelocations += "$certpath\machine\new_machine.cer"
	$filelocations += "$SslPath/new_machine.cer"
	$filelocations += "$certpath\machine\ssl_key.priv"
	$filelocations += "$SslPath/ssl_key.priv"
	if ($servertype -ieq "Infrastructure"){
		$filelocations += "$Cert_Dir\chain.cer"
		$filelocations += "$SslPath/chain.cer"}
	if ($pscdeployments -contains $servertype) {
		$filelocations += "$Cert_Dir\root64.cer"
		$filelocations += "$SslPath/root64.cer"
		$filelocations += "$Cert_Dir\interm64.cer"
		$filelocations += "$SslPath/interm64.cer"
		$filelocations += "$Cert_Dir\interm264.cer"
		$filelocations += "$SslPath/interm264.cer"}
	
	$filelocations += "$certpath\vmdir\vmdircert.pem"
	$filelocations += "/usr/lib/vmware-vmdir/share/config/vmdircert.pem"
	$filelocations += "$certpath\vmdir\vmdirkey.pem"
	$filelocations += "/usr/lib/vmware-vmdir/share/config/vmdirkey.pem"

	$filelocations += "$certpath\solution\machine.cer"
	$filelocations += "$SolutionPath/machine.cer"
	$filelocations += "$certpath\solution\machine.priv"
	$filelocations += "$SolutionPath/machine.priv"
	$filelocations += "$certpath\solution\vsphere-webclient.cer"
	$filelocations += "$SolutionPath/vsphere-webclient.cer"
	$filelocations += "$certpath\solution\vsphere-webclient.priv"
	$filelocations += "$SolutionPath/vsphere-webclient.priv"
	if ($servertype -ine "Infrastructure"){
		$filelocations += "$certpath\solution\vpxd.cer"
		$filelocations += "$SolutionPath/vpxd.cer"
		$filelocations += "$certpath\solution\vpxd.priv"
		$filelocations += "$SolutionPath/vpxd.priv"
		$filelocations += "$certpath\solution\vpxd-extension.cer"
		$filelocations += "$SolutionPath/vpxd-extension.cer"
		$filelocations += "$certpath\solution\vpxd-extension.priv"
		$filelocations += "$SolutionPath/vpxd-extension.priv"}
	
	CopyFiletoServer $filelocations $hostname $username $password
	
	$commandlist = $null
	$commandlist = @()
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"	
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	$commandlist += "service-control --stop --all"
	$commandlist += "service-control --start vmafdd"
	$commandlist += "service-control --start vmdird"
	$commandlist += "service-control --start vmca"

	# Replace the root cert.
	if ($pscdeployments -contains $servertype) {
		$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/root64.cer"
		$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/interm64.cer"
		$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $SslPath/interm264.cer"}

    #Replace the Machine Cert.
	$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store MACHINE_SSL_CERT --alias __MACHINE_CERT"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store MACHINE_SSL_CERT --alias __MACHINE_CERT --cert $SslPath/new_machine.cer --key $SslPath/ssl_key.priv"

	
	ExecuteScript $commandlist $hostname $username $password

	$commandlist = $null
	$commandlist = @()
	$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store machine --alias machine" 
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store machine --alias machine --cert $SolutionPath/machine.cer --key $SolutionPath/machine.priv"
	$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vsphere-webclient --alias vsphere-webclient"
	$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vsphere-webclient --alias vsphere-webclient --cert $SolutionPath/vsphere-webclient.cer --key $SolutionPath/vsphere-webclient.priv"
	#Skip if server is an External PSC.
	if ($servertype -ine "Infrastructure"){
		$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd --alias vpxd"
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd --alias vpxd --cert $SolutionPath/vpxd.cer --key $SolutionPath/vpxd.priv"
		$commandlist += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd-extension --alias vpxd-extension"	
		$commandlist += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd-extension --alias vpxd-extension --cert $SolutionPath/vpxd-extension.cer --key $SolutionPath/vpxd-extension.priv"
	}

	ExecuteScript $commandlist $hostname $username $password
	
	$commandlist = $null
	$commandlist = @()
	$commandlist += "/usr/lib/vmware-vmafd/bin/vmafd-cli get-machine-id --server-name localhost"
	$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli service list"
	
	$UniqueID = Invoke-VMScript -ScriptText $commandlist[0] -vm $hostname -GuestUser $username -GuestPassword $password
	$CertList = Invoke-VMScript -ScriptText $commandlist[1] -vm $hostname -GuestUser $username -GuestPassword $password
	
	#Retrieve unique key list relevant to the server.
	$SolutionUsers = ($Certlist.ScriptOutput.split(".").Split("`n")|%{if($_[0] -eq " "){$_}} | ?{$_.ToString() -ilike "*$($UniqueID.ScriptOutput.split("`n")[0])*"}).Trim(" ")

	$commandlist = $null
	$commandlist = @()

	$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli service update --name $($SolutionUsers[0]) --cert $SolutionPath/machine.cer"
	$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli service update --name $($SolutionUsers[1]) --cert $SolutionPath/vsphere-webclient.cer"
	if ($servertype -ine "Infrastructure") {
		$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli service update --name $($SolutionUsers[2]) --cert $SolutionPath/vpxd.cer"
		$commandlist += "echo `'$password`' | /usr/lib/vmware-vmafd/bin/dir-cli service update --name $($SolutionUsers[3]) --cert $SolutionPath/vpxd-extension.cer"}
		
	$commandlist += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
	$commandlist += "export VMWARE_LOG_DIR=/var/log"	
	$commandlist += "export VMWARE_CFG_DIR=/etc/vmware"
	$commandlist += "export VMWARE_DATA_DIR=/storage"
	$commandlist += "service-control --start --all"
	
	#Service update
	ExecuteScript $commandlist $hostname $username $password
}

function UserPEMFiles {
	# Creates PEM files for all solution user certificates
	Get-ChildItem -Path $Cert_Dir -filter "*.csr" | foreach {
		$Dir = $_.basename
		CreatePEMFiles $Dir "$Dir.crt" "$Dir.cer"
	}
  
}

function VMDirRename ($Cert_Dir) {
	# Renames SSL certificate files to those used by VCSA
	Rename-Item $Cert_Dir\VMDir\VMDir.cer vmdircert.pem
	Rename-Item $Cert_Dir\VMDir\VMDir.priv vmdirkey.pem
	Write-host "Certificate files renamed. Upload \VMDir\vmdircert.pem and \VMDir\vmdirkey.pem" -ForegroundColor Yellow
	Write-host "to VCSA at /usr/lib/vmware-dir/share/config" -ForegroundColor Yellow
}

function VMCAMint ($SVCDir, $CFGFile, $CertFile, $PrivFile) {
	# This function issues a new SSL certificate from the VMCA.
	if(!(Test-Path $Cert_Dir\$SVCDir)) {New-Item $Cert_Dir\$SVCDir -Type Directory}
	$Computername = get-wmiobject win32_computersystem
	$DEFFQDN = "$($computername.name).$($computername.domain)".ToLower() 
	$MachineFQDN = $(
		Write-Host "Do you want to replace the SSL certificate on $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
		if ($InputFQDN) {$InputFQDN} else {$DEFFQDN}
	)
	$PSCFQDN = $(
		Write-Host "Is the PSC $DEFFQDN ?"
		$InputFQDN = Read-Host "Press ENTER to accept or input the correct PSC FQDN"
		if ($InputFQDN) {$InputFQDN} else {$DEFFQDN}
	)
	$MachineIP = [System.Net.Dns]::GetHostAddresses("$MachineFQDN").IPAddressToString -like '*.*'
	write-host $MachineIP
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
	cd "C:\Program Files\VMware\vCenter Server\vmcad"
	.\certool --genkey --privkey=$Cert_Dir\$SVCDir\$PrivFile --pubkey=$Cert_Dir\$SVCDir\$SVCDir.pub
	.\certool --gencert --cert=$Cert_Dir\$SVCDir\$CertFile --privkey=$Cert_Dir\$SVCDir\$PrivFile --config=$Cert_Dir\$SVCDir\$CFGFile --server=$PSCFQDN
	if (Test-Path $Cert_Dir\$SVCDir\$CertFile) {write-host "PEM file located at $Cert_Dir\$SVCDir\new_machine.cer" -ForegroundColor Yellow n}
}

function CDDir ($PSScriptRoot) {
	# CDs into the directory the Toolkit script was run
	cd $PSScriptRoot
}

function CreateVCSolutionCert ($Cert_Dir, $InstanceCertDir, $Certinfo, $Template, $ISSUING_CA) {
	CreateSolutionCSR Solution vpxd.csr vpxd.cfg vpxd.priv 6 vpxd $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vpxd-extension.csr vpxd-extension.cfg vpxd-extension.priv 6 vpxd-extension $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo
	
	OnlineMint Solution vpxd.csr vpxd.crt $Template $InstanceCertDir $ISSUING_CA
	OnlineMint Solution vpxd-extension.csr vpxd-extension.crt $Template $InstanceCertDir $ISSUING_CA
	OnlineMint Solution machine.csr machine.crt $Template $InstanceCertDir $ISSUING_CA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Template $InstanceCertDir $ISSUING_CA
	
	CreatePEMFiles Solution vpxd.crt vpxd.cer $Cert_Dir $InstanceCertDir
	CreatePEMFiles Solution vpxd-extension.crt vpxd-extension.cer $Cert_Dir $InstanceCertDir
	CreatePEMFiles Solution machine.crt machine.cer $Cert_Dir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $Cert_Dir $InstanceCertDir
}

function CreatePscSolutionCert ($Cert_Dir, $InstanceCertDir, $Certinfo, $Template, $ISSUING_CA) {
	CreateSolutionCSR Solution machine.csr machine.cfg machine.priv 6 machine $InstanceCertDir $Certinfo
	CreateSolutionCSR Solution vsphere-webclient.csr vsphere-webclient.cfg vsphere-webclient.priv 6 vsphere-webclient $InstanceCertDir $Certinfo

	OnlineMint Solution machine.csr machine.crt $Template $InstanceCertDir $ISSUING_CA
	OnlineMint Solution vsphere-webclient.csr vsphere-webclient.crt $Template $InstanceCertDir $ISSUING_CA
	
	CreatePEMFiles Solution machine.crt machine.cer $Cert_Dir $InstanceCertDir
	CreatePEMFiles Solution vsphere-webclient.crt vsphere-webclient.cer $Cert_Dir $InstanceCertDir
}

# End Functions

# PSScriptRoot does not have a trailing "\"
$PSScriptRoot  		   = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Start New Transcript
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$OutputPath = "$PSScriptRoot\DeployLog_" + $(Get-date -format "dd-MM-yyyy_HH-mm") + ".txt"
Start-Transcript -path $OutputPath -append

Separatorline

#Check to see if Powershell is at least version 3.0
$PSpath = "HKLM:\SOFTWARE\Microsoft\PowerShell\3"
if (!(Test-Path $PSpath)) {
	write-host "PowerShell 3.0 or higher required. Please install"; exit 
}

# Load Modules and/or Snapins
# Get PowerCli version
$pcli_version = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.displayname -ilike "*powercli*"}).displayversion

if ($pcli_version -lt 6)
	{
	 $Snapin = ("VMware.VimAutomation.Core","VMware.VimAutomation.vds")
 
	 foreach ($S in $Snapin){
		 if ((Get-PSSnapin -Name $S -ErrorAction SilentlyContinue) -eq $null )
		 {
			 Add-PsSnapin $S
		 }
	 }
	}
else
	{
	 Import-Module VMware.VimAutomation.Core
	 Import-Module VMware.VimAutomation.vds
	}
	
Separatorline

# Check the version of Ovftool and get it's path. Search C:\program files\ and C:\Program Files (x86)\ subfolders for vmware and find the
# Ovftool folders. Then check the version and return the first one that is version 4 or higher.
$ovftoolpath = (gci (gci $env:ProgramFiles, ${env:ProgramFiles(x86)} -filter vmware).fullname -recurse -filter ovftool.exe | %{if(!((& $($_.DirectoryName+"\ovftool.exe") --version).split(" ")[2] -lt 4.0.0)){$_}} | Select -first 1).DirectoryName

# Check ovftool version
if (!$ovftoolpath) 
	{write-host "Script requires installation of ovftool 4.0.0 or newer";
	 Exit} 
else
	{write-host "ovftool version OK `r`n"}
	
# Get list of installed Applications
$InstalledApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |?{$_.DisplayName} | Sort
	
# Download OpenSSL if it's not already installed
if (!($InstalledApps | ?{$_.DisplayName -ilike "*openssl*"})) {
Write-Host -Foreground "DarkBlue" -Background "White" "Downloading OpenSSL $OpenSSLVersion ..."
$null = New-Item -Type Directory $openssldir -erroraction silentlycontinue
$sslurl = "http://slproweb.com/download/$OpenSSLVersion"
$sslexe = "$env:temp\openssl.exe"
$wc.DownloadFile($sslurl,$sslexe)
$env:path = $env:path + ";$openssldir"
    if (!(test-Path($sslexe))) { write-host -Foreground "red" -Background "white" "Could not download or find OpenSSL. Please install the latest OpenSSL 0.9.8 manually or update download name."; exit}
Write-Host -Foreground "DarkBlue" -Background "White" "Installing OpenSSL..."
    cmd /c $sslexe /silent /verysilent /sp- /suppressmsgboxes
Remove-Item $sslexe
}

$openssl = ($InstalledApps | ?{$_.DisplayName -ilike "*openssl*"}).InstallLocation + "bin\openssl.exe"

#Check for openssl
CheckOpenSSL $openssl

Separatorline

# ---------------------  Load Parameters from Excel ------------------------------

# Global variables
$ExcelFilePath = "$PSScriptRoot\vsphere-configs.xlsx"

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
$workBook = $objExcel.Workbooks.Open($ExcelFilePath)

# get ad info
$workSheet			= $WorkBook.sheets.item("adinfo")
$rows				= $WorkSheet.UsedRange.Rows.Count
[string[]]$s_adinfo	= $Worksheet.Range("B2","B$rows").Value().split("`n")

Echo $s_adinfo

Separatorline

# get certificate info
$workSheet				= $WorkBook.sheets.item("certs")
$rows					= $WorkSheet.UsedRange.Rows.Count
[string[]]$s_certinfo	= $Worksheet.Range("B2","B$rows").Value().split("`n")

Echo $s_certinfo

Separatorline

# get clusters
$workSheet	= $WorkBook.sheets.item("clusters")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data 		= $Worksheet.Range("A2","C$rows").Value()
$s_clusters = @()

for ($i=1;$i -lt $rows;$i++){
		$s_cluster = New-Object System.Object
		$s_cluster | Add-Member -type NoteProperty -name ClusterName -value $data[$i,1]
		$s_cluster | Add-Member -type NoteProperty -name Datacenter -value $data[$i,2]
		$s_cluster | Add-Member -type NoteProperty -name vCenter -value $data[$i,3]
		$s_clusters += $s_cluster
}

Echo $s_clusters

Separatorline

# get folders
$workSheet	= $WorkBook.sheets.item("folders")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data		= $Worksheet.Range("A2","E$rows").Value()
$s_folders	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_folder = New-Object System.Object
		$s_folder | Add-Member -type NoteProperty -name Name -value $data[$i,1]
		$s_folder | Add-Member -type NoteProperty -name Location -value $data[$i,2]
		$s_folder | Add-Member -type NoteProperty -name Type -value $data[$i,3]
		$s_folder | Add-Member -type NoteProperty -name Datacenter -value $data[$i,4]
		$s_folder | Add-Member -type NoteProperty -name vCenter -value $data[$i,5]
		$s_folders += $s_folder
}

Echo $s_folders

Separatorline

# get Permissions
$workSheet		= $WorkBook.sheets.item("permissions")
$rows			= $WorkSheet.UsedRange.Rows.Count
$data			= $Worksheet.Range("A2","E$rows").Value()
$s_Permissions	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_Permission = New-Object System.Object
		$s_Permission | Add-Member -type NoteProperty -name Entity -value $data[$i,1]
		$s_Permission | Add-Member -type NoteProperty -name Principal -value $data[$i,2]	
		$s_Permission | Add-Member -type NoteProperty -name Propagate -value $data[$i,3]	
		$s_Permission | Add-Member -type NoteProperty -name Role -value $data[$i,4]
		$s_Permission | Add-Member -type NoteProperty -name vCenter -value $data[$i,5]
		$s_Permissions += $s_Permission
}

Echo $s_Permissions

Separatorline

# get OS Customizations
$workSheet			= $WorkBook.sheets.item("OS")
$rows				= $WorkSheet.UsedRange.Rows.Count
$data				= $Worksheet.Range("A2","AA$rows").Value()
$s_Customizations	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_Customization = New-Object System.Object
		$s_Customization	= ""
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
		if ($data[$i,14] -ilike "true") {$s_Customization = $s_Customization.insert($s_Customization.length," -ChangeSid")}
		if ($data[$i,15] -ilike "true") {$s_Customization = $s_Customization.insert($s_Customization.length," -DeleteAccounts")}
		if ($data[$i,16]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Gui `"$($data[$i,16])`"")}
		if ($data[$i,17]) {$s_Customization = $s_Customization.insert($s_Customization.length," -RunOnce `"$($data[$i,17])`"")}
		if ($data[$i,18]) {$s_Customization = $s_Customization.insert($s_Customization.length," -AdminPassword `"$($data[$i,18])`"")}
		if ($data[$i,19]) {$s_Customization = $s_Customization.insert($s_Customization.length," -TimeZone `"$($data[$i,19])`"")}
		if ($data[$i,20]) {$s_Customization = $s_Customization.insert($s_Customization.length," -AutoLogonCount $($data[$i,20])")}
		if ($data[$i,21]) {$s_Customization = $s_Customization.insert($s_Customization.length," -Workgroup `"$($data[$i,21])`"")}
		if ($data[$i,22]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DomainUsername `"$($data[$i,22])`"")}
		if ($data[$i,23]) {$s_Customization = $s_Customization.insert($s_Customization.length," -DomainPassword `"$($data[$i,23])`"")}
		if ($data[$i,24]) {$s_Customization = $s_Customization.insert($s_Customization.length," -ProductKey `"$($data[$i,24])`"")}
		if ($data[$i,25]) {$s_Customization = $s_Customization.insert($s_Customization.length," -LicenseMode $($data[$i,25])")}
		if ($data[$i,26]) {$s_Customization = $s_Customization.insert($s_Customization.length," -LicenseMaxConnections $($data[$i,26])")}
		$s_Customizations += $s_Customization.insert(0,"New-OSCustomizationSpec")
}

Echo $s_Customizations

Separatorline

# get Roles
$workSheet	= $WorkBook.sheets.item("roles")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data		= $Worksheet.Range("A2","C$rows").Value()
$s_Roles	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_Role = New-Object System.Object
		$s_Role | Add-Member -type NoteProperty -name Name -value $data[$i,1]
		$s_Role | Add-Member -type NoteProperty -name Privilege -value $data[$i,2]
		$s_Role | Add-Member -type NoteProperty -name vCenter -value $data[$i,3]
		$s_Roles += $s_Role
}

Echo $s_Roles

Separatorline

# get Services
$workSheet	= $WorkBook.sheets.item("services")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data		= $Worksheet.Range("A2","B$rows").Value()
$s_Services	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_Service = New-Object System.Object
		$s_Service | Add-Member -type NoteProperty -name Node -value $data[$i,1]
		$s_Service | Add-Member -type NoteProperty -name Service -value $data[$i,2]
		$s_Services += $s_Service
}

Echo $s_Services

Separatorline

# get sites
$workSheet	= $WorkBook.sheets.item("sites")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data 		= $Worksheet.Range("A2","E$rows").Value()
$s_sites	= @()
	
for ($i=1;$i -lt $rows;$i++){
	$s_site = New-Object System.Object
	$s_site | Add-Member -type NoteProperty -name Datacenter -value $data[$i,1]
	$s_site | Add-Member -type NoteProperty -name oct1 -value $data[$i,2]
	$s_site | Add-Member -type NoteProperty -name oct2 -value $data[$i,3]
	$s_site | Add-Member -type NoteProperty -name oct3 -value $data[$i,4]
	$s_site | Add-Member -type NoteProperty -name vCenter -value $data[$i,5]
	$s_sites += $s_site
	}
	
Echo $s_sites

Separatorline

# get vcsa
$workSheet			= $WorkBook.sheets.item("vcsa")
$rows				= $WorkSheet.UsedRange.Rows.Count
[string[]]$s_vcsas	= $Worksheet.Range("B1","B$rows").Value().split("`n")

Echo $s_vcsas

Separatorline

# get vdswitches
$workSheet		= $WorkBook.sheets.item("vdswitches")
$rows			= $WorkSheet.UsedRange.Rows.Count
$data 			= $Worksheet.Range("A2","D$rows").Value()
$s_vdswitches	= @()

for ($i=1;$i -lt $rows;$i++){
	$s_vdswitch = New-Object System.Object
	$s_vdswitch | Add-Member -type NoteProperty -name vDSwitchName -value $($data[$i,1].ToString() + " " + $data[$i,2].ToString())
	$s_vdswitch | Add-Member -type NoteProperty -name Location -value $data[$i,3]
	$s_vdswitch | Add-Member -type NoteProperty -name vCenter -value $data[$i,4]
	$s_vdswitches += $s_vdswitch
	}

Echo $s_vdswitches
	
Separatorline

# get vlans
$workSheet	= $WorkBook.sheets.item("vlans")
$rows		= $WorkSheet.UsedRange.Rows.Count
$data		= $Worksheet.Range("A2","E$rows").Value()
$s_vlans 	= @()

for ($i=1;$i -lt $rows;$i++){
		$s_vlan = New-Object System.Object
		$s_vlan | Add-Member -type NoteProperty -name vlan -value $($data[$i,1].padright(8," ") +`
																	$data[$i,2].padright(8," ") + "- " +`
																	$data[$i,3].padright(19," ") + "- " +`
																	$data[$i,4])
		$s_vlan | Add-Member -type NoteProperty -name vCenter -value $data[$i,5]
		$s_vlans += $s_vlan
}

Echo $s_vlans

Separatorline

$workbook.Close($false)

# ---------------------  END Load Parameters from Excel ------------------------------

# Global variables
[regex]$regex				= '\d{2,4}'
$pscdeployments				= @("tiny","small","large","infrastructure")
$mtu						= "9000"
$ova 						= "$PSScriptRoot\vmware-vcsa"

# Certificate variables	
# Create the RANDFILE environmental parameter for openssl to fuction properly.
$env:RANDFILE 					= "$PSScriptRoot\Certs\.rnd"
$rootcer						= "$PSScriptRoot\Certs\root64.cer"
$intermcer 						= "$PSScriptRoot\Certs\interm64.cer" 
$interm2cer 					= "$PSScriptRoot\Certs\interm264.cer" 
$wc 							= New-Object System.Net.WebClient
$wc.UseDefaultCredentials 		= $true
$Script:CertsWaitingForApproval = $false
New-Alias -Name OpenSSL $openssl

# Create certificate directory if it does not exist
$Cert_Dir = $PSScriptRoot + "\Certs"
if (!(Test-Path $Cert_Dir)) { New-Item $Cert_Dir -Type Directory | out-null }

# Deploy the VCSA servers.
# $Deployments - Number of VCSAs to deploy
$Deployments = ($s_vcsas.length / 23) - 1

for ($i=0; $i -le $Deployments; $i++) {

	# $min = Start index for current deployment.
	# $max = End index for current deployment.
	$min = $i * 23
	$max = $min + 22

	# Skip deployment if set to null.
	if ($s_vcsas[$min] -ine "null") {

		Write-host "`r`n Deploying $($s_vcsas[$min + 2]) now.`r`n" -foregroundcolor cyan
	
		# Deploy the vcsa
		Deploy $s_vcsas[$min..$max] $ovftoolpath

		# Write separator line to transcript.
		Separatorline
	
		# Wait until the vcsa is available.
		Available("https://$($s_vcsas[$min + 2])")
	
		Write-Host "`r`n The VCSA $($s_vcsas[$min + 2]) has been deployed and is available.`r`n" -foregroundcolor cyan
	
		# Write separator line to transcript.
		Separatorline
	}
}

# Wait 90 seconds before continuing to give the vcsa enough time for all services to start.
Start-Sleep -s 90

# Clear index variables.
$min = $null
$max = $null

for ($i=0; $i -le $Deployments; $i++) {

	# $min = Start index for current deployment.
	# $max = End index for current deployment.
	$min = $i * 23
	$max = $min + 22
	
	# Skip deployment if set to null.
	if ($s_vcsas[$min] -ine "null") {
	
		# Create esxi credentials.
		$esxi_secpasswd		= ConvertTo-SecureString $s_vcsas[$min + 18] -AsPlainText -Force
		$esxi_creds			= New-Object System.Management.Automation.PSCredential ($s_vcsas[$min + 17], $esxi_secpasswd)
	
		# Connect to esxi host of the deployed vcsa.
		$DeploymentEsxiHost = connect-viserver -server $s_vcsas[$min + 14] -credential $esxi_creds

		# if the vcsa is a PSC, join it to the windows domain.
		if ($pscdeployments -contains $s_vcsas[$min + 13]) {
			$commandlist = $null
			$commandlist = @()
			
			$commandlist += "echo `'$($s_vcsas[$min + 3])`' | appliancesh shell.set --enabled true"
			$commandlist += "echo `'$($s_vcsas[$min + 3])`' | appliancesh shell"
			$commandlist += "/opt/likewise/bin/domainjoin-cli join $($s_adinfo[0]) $($s_adinfo[1]) $($s_adinfo[2])"
			$commandlist += "reboot"
			
			# Excute the commands in $commandlist on the vcsa.
			ExecuteScript $commandlist $s_vcsas[$min + 2] "root" $s_vcsas[$min + 3]

			# Write separator line to transcript.
			Separatorline
			
			# Wait 60 seconds before checking availability to make sure the vcsa is booting up and not in the process of shutting down.
			Start-Sleep -s 60
			
			# Wait until the vcsa is available.
			Available("https://$($s_vcsas[$min + 2])")
			
			# Write separator line to transcript.
			Separatorline
		}
		
		# if the vcsa is the first PSC in the vsphere domain, set the default identity source to the windows domain,
		# add the windows AD group to the admin groups of the PSC.
		if ($s_vcsas[$min] -ieq "first" -and $pscdeployments -contains $s_vcsas[$min + 13]) {
			ConfigureIdentity $s_vcsas[$min + 20] $s_vcsas[$min + 2] $s_vcsas[$min + 3] $s_adinfo[0] $s_adinfo[3]
		}

		# Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
		$s_certinfo[4] = $s_vcsas[$min + 2]
		
		# $InstanceCertDir is the script location plus cert folder and hostname eg. C:\Script\Certs\vm-host1.companyname.com\
		$InstanceCertDir = $Cert_Dir + "\" + $s_vcsas[$min + 2]
		
		# Check for or download root certificates.
		DownloadRoots $Cert_Dir	$s_certinfo[1] $rootcer $s_certinfo[2] $intermcer $s_certinfo[3] $interm2cer $s_certinfo[11]
		
		# Check for or create certificate chain.
		ChainCAs $Cert_Dir $rootcer $intermcer $interm2cer
		
		# Create the Machine cert.
		CreateCSR machine machine_ssl.csr machine_ssl.cfg ssl_key.priv 6 $InstanceCertDir $s_certinfo[4..10]
		OnlineMint machine machine_ssl.csr new_machine.crt $s_certinfo[14] $InstanceCertDir $s_certinfo[12]
		CreatePEMFiles machine new_machine.crt new_machine.cer $Cert_Dir $InstanceCertDir
		
		# Change back to the script root folder.
		CDDir $PSScriptRoot

		# Create the VMDir cert.
		CreateCSR VMDir VMDir.csr VMDir.cfg VMDir.priv 6 $InstanceCertDir $s_certinfo[4..10]
		OnlineMint VMDir VMDir.csr VMDir.crt $s_certinfo[14] $InstanceCertDir $s_certinfo[12]
		CreatePEMFiles VMDir VMDir.crt VMdir.cer $Cert_Dir $InstanceCertDir
		
		# Rename the VMDir cert for use on a VMSA.
		VMDirRename $InstanceCertDir
		
		# Change back to the script root folder.		
		CDDir $PSScriptRoot

		# Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
		if ($s_vcsas[$min + 13] -ieq "infrastructure" ) {
			CreatePscSolutionCert $Cert_Dir $InstanceCertDir $s_certinfo[4..10] $s_certinfo[14] $s_certinfo[12]
		}
		else {CreateVCSolutionCert $Cert_Dir $InstanceCertDir $s_certinfo[4..10] $s_certinfo[14] $s_certinfo[12]}
		
		# Copy Cert files to vcsa Node and deploy them.
		TransferCerttoNode $Cert_Dir $s_vcsas[$min + 13] $s_vcsas[$min + 2] "root" $s_vcsas[$min + 3]
		
		# Write separator line to transcript.
		Separatorline
		
		# if the vcsa is not a stand alone PSC, configure the vCenter.
		if ($s_vcsas[$min + 13] -ine "infrastructure" ) {

			$Datacenters	= $s_sites | ?{$_.vCenter -ieq "all" -or $_.vCenter -ilike $s_vcsas[$min + 2]}
			$sso_secpasswd	= ConvertTo-SecureString $($s_vcsas[$min + 22]) -AsPlainText -Force
			$sso_creds		= New-Object System.Management.Automation.PSCredential ("Administrator@$($s_vcsas[$min + 20])", $sso_secpasswd)
			
			#
			# vCenter Configs
			#
			
			# Wait until the vcsa is available.
			Available("https://$($s_vcsas[$min + 2])")
			
			# Connect to the vCenter
			$vc = Connect-viserver $s_vcsas[$min + 2] -Credential $sso_creds
			
			# Create Datacenter
			$Datacenters.Datacenter.ToUpper() | %{New-Datacenter -Location Datacenters -Name $_}
				
			# Create Folders, Roles, and Permissions.
			$folders = $s_folders | ?{$_.vCenter -ieq "all" -or $_.vCenter -ilike $s_vcsas[$min + 2]}
			echo "Folders:" $folders
			CreateFolders $folders $vc

			# if this is the first vCenter, create custom Roles.
			if ($s_vcsas[$min] -ieq "first" ) {
				$roles = $s_roles | ?{$_.vCenter -ieq "all" -or $_.vCenter -ilike $s_vcsas[$min + 2]}
				echo  "Roles:" $roles
				CreateRoles $roles $vc	
			}
			
			# Create OS Customizations for the vCenter.
			$s_Customizations | ?{$_ -ilike "*$($s_vcsas[$min + 2])*"} | %{Invoke-Expression $_; echo $_}
			
			# Create Clusters
			foreach ($Datacenter in $Datacenters) {
				# Define IP Octets
				$oct1 = $Datacenter.oct1
				$oct2 = $Datacenter.oct2
				$oct3 = $Datacenter.oct3
			
				# Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
				($s_clusters | ?{@("all",$s_vcsas[$min + 2]) -ieq $_.vCenter`
					-and $Datacenter.Datacenter -ieq $_.Datacenter}).Clustername |`
					%{if ($_) {New-Cluster -Location (Get-Datacenter -Server $vc -Name $Datacenter.Datacenter) -Name $_}}
						
				# Create New vDSwitch
				# Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
				$vdswitches = $s_vdswitches | ?{@("all",$s_vcsas[$min + 2]) -ieq $_.vCenter -and $_.Location -ieq $Datacenter.Datacenter}
				foreach ($vdswitch in $vdswitches) {
				
					$SwitchLocation = Get-Inventory -Name $vdswitch.location
				
					# Create new vdswitch.
					New-VDSwitch -Server $vc -Name $vdswitch.vDSwitchName -Location $SwitchLocation -Mtu $mtu -NumUplinkPorts 2
					
					#Enable NIOC
					(get-vdswitch -Server $vc -Name $vdswitch.vDSwitchName | get-view).EnableNetworkResourceManagement($true)
				
					#Create Portgroups
					foreach ($vlan in $($s_vlans.vlan | ?{$_.StartsWith($vdswitch.vDSwitchName.split(" ")[0])})) {
					
						$vlan = $vlan -replace "oct1", $oct1
						$vlan = $vlan -replace "oct2", $oct2
						$vlan = $vlan -replace "oct2", $oct3
						
						New-VDPortgroup -Server $vc -VDSwitch $vdswitch.vDSwitchName -Name $vlan -Notes $vlan.split("-")[0] -VlanId $regex.matches($vlan)[0].value
						
						#Set Portgroup Team policies
						if ($vlan -ilike "*vmotion-1*") {
							Get-vdportgroup -Server $vc | ?{$_.Name.split('%')[0] -ilike $vlan.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vc | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
						}
						if ($vlan -ilike "*vmotion-2*") {
							Get-vdportgroup -Server $vc | ?{$_.Name.split('%')[0] -ilike $vlan.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vc | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
						}
						if ($vlan -inotlike "*vmotion*") {
							Get-vdportgroup -Server $vc | ?{$_.Name.split('%')[0] -ilike $vlan.split('/')[0]} | Get-VDUplinkTeamingPolicy -Server $vc | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
						}
						else
						{
						#Set Traffic Shaping on vmotion portgroups for egress traffic
						Get-VDPortgroup -Server $vc -VDSwitch $vdswitch.vDSwitchName | ?{$_.Name.split('%')[0] -ilike $vlan.split('/')[0]} | Get-VDTrafficShapingPolicy -Server $vc -Direction Out| Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
						}
					}
				}
			}
			
			# Select permissions for all vCenters or the current vCenter.
			$Permissions = $s_Permissions | ?{$_.vCenter -ieq "all" -or $_.vCenter -ilike $s_vcsas[$min + 2]}
			
			echo  "Permissions:" $permissions
			
			# Create the permissions.
			CreatePermissions $Permissions $vc
			
			# Configure Additional Services (Network Dump, Autodeploy, TFTP)
			foreach ($serv in $s_Services) {
				if ($serv.node -eq $s_vcsas[$min + 2]) {
					switch ($serv.Service) {
						AutoDeploy	{ ConfigureAutoDeploy $s_vcsas[$min + 7] $s_vcsas[$min + 2] "root" $s_vcsas[$min + 3] $($s_vcsas[$min + 20])}
						Netdumpster	{ ConfigureNetdumpster $s_vcsas[$min + 2] "root" $s_vcsas[$min + 3]}
						TFTP		{ ConfigureTFTP $s_vcsas[$min + 2] "root" $s_vcsas[$min + 3]}
					}
				}
			}
			
			# Disconnect from the vCenter.
			Disconnect-viserver -server $vc -Confirm:$false	
		}
	
		# Disconnect from the vcsa deployed esxi server.
		Disconnect-viserver -Server $DeploymentEsxiHost -Confirm:$false
	}
}

# Stop the transcript.
Stop-Transcript