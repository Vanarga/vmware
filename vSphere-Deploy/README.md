# Welcome to the vSphere 6.5/6.7 Deployment Readme! #

**7-25-2017**: Finally had some time to update the wiki, which explains in some detail what this project does. The Phase 2 page, details how the script replaces all the vCenter Certificates with a Microsoft Certificate Authority without using the VMCA or the Certificate utility on the VCSA (my only complaint about the on board Certificate utility is that it does not accept command line parameters).

***

**Important Note: A couple of the methods I use to configure the PSC/vCenter are not supported by VMWare. Please take this in to account if you are going to use this for a Production Deployment.**

***

### Functionality: ###
   - Deploy multiple vcsa from ovf.
     * Deployments can be any supported e.g. PSC, vCenter, Stand alone, Combined, etc.
     * Can be deployed to different networks and different hosts.
     * Supports different disk modes e.g. thin, thick, thick eager zero.

   - Configurations
     * Join to a windows domain.
     * Set windows domain as primary identity source.
     * Add windows group as Administrative group to PSC.
     * Create Datacenters.
     * Create Folders.
     * Create Roles.
     * Create Permissions.
     * Create vdSwitches.
     * Create Port Groups/VLANs
     * Create OS customizations.
     * Create and Replace Certs from an external windows CA for:
     * VCSA Machine Cert.
     * vmdir Cert.
     * Solution User Certs.
     * VAMI Cert.
     * Configure Services for Autodeploy, Network Dump, and TFTP.
     * Add licenses and assign licenses.
     * Import VMHost Profile.
     * Configure Autodeploy Rules.

### New Features: ###
- Added support for json configuration files.
- Added support for yaml configuration files.
- Script can convert between excel/json/yaml files with run-time parameters.
- Added external script to convert between excel/json/yaml files.
- Added ability to set the default folder path as a run-time parameter.

### To be done: ###
- Create a usable test vsphere-config.xlsx file.
- Reconfigure different types of vdswitch creation for full flexibility.
- Test and add functionality for multi part certificate replacement.
- Create certificates for Load Balancers.
- Test VMCA certificate deployment.
- Add prompt for credentials instead of reading from Excel?
- Fix Change Root Password on VMHost Profile - currently not working.

### Completed ###
- Resolved adding Active Directory as an Identity Source.
- Resolved correctly closing Excel so that it does not stay in memory.
- Test Autodeploy that is configured by the script. - Successfully tested!
- Add ability to load add-ons in to vcenter and register them, e.g. Onyx. - Successful.
- Tested deployment with external PSC and combined.

Excel Configuration File (vsphere-config.xlsx)	- Needs to be in the script folder when the script is executed.
The vSphere config file contains the following tabs:

## Summary ##  
| Field | Valid values | Notes |
| ----- | ------------ | ----- |
| Post Completion Transcript Password Scrub | True/False | Redacts all passwords from the transcript log if set to TRUE. |

## adinfo ##  
| Field | Valid values | Notes |
| ----- | ------------ | ----- |
| AD Domain  | AD Domain Name e.g hcmny.com |
| AD Domain Join Account  | Active Directory Account with join delegation |
| AD Domain Join Password | Password between two single quotes inside double quotes e.g. "'password'" |
| AD vCenter Admins | Name of AD domain group to give SSO Admin Rights e.g. groupname |
| AD ESXi Domain Join Account | AD Account to use with vSphere Authentication Proxy to join esxi hosts to domain. |
| AD ESXi Domain Join Password | Password between two single quotes inside double quotes e.g. "'password'" |
| vCenter | Which Node to use these domain credentials with. |

## autodeploy ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| vCenter | vCenter FQDN string. |
| RuleName | Autodeploy rule name string. |
| ProfileImport | Profile file name, Defalt location is script folder e.g. Profile.vpf |
| ProfileName | Autodeploy profile name string. e.g. Production Server Build |
| ProfileRootPassword | Sets AutoDeployed Server Root Password |
| ProfileAnnotation | Auto Deploy Profile Annotation - just a text string. |
| Datacenter | Datacenter to attach autodeploy servers to. |
| Cluster | Cluster to attach autodeploy servers to. |
| SoftwareDepot | Software Depot to Autodeploy from. |
| Pattern | Pattern to target autodeploy servers from. e.g. ipv4=10.0.0.10-10.0.0.250 |
| Activate | Enable Autodeploy rule. TRUE/False |

##  certs ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Open SSL DIR  | Folder to install OpenSSL in. e.g. C:\OpenSSL |
| Root CA  | FQDN of root CA e.g. cert1.acme.com |
| Subordinate CA 1  | FQDN of 1st subordinate CA e.g. cert2.acme.com |
| Subordinate CA 2  | FQDN of 2nd subordinate CA e.g. cert3.acme.com |
| Username  | Username of credential to connect to the Certificate Authority (always the last server in the chain). |
| Password  | Password to connect to Certificate Authority. |
| Common Name  | Should be set to the letters FQDN, which will be replaced during runtime by the FQDN of the Server. |
| Orginzation Name  | Company Name e.g. Acme Inc. |
| Orgizational Unit  | Name of Organization with the Company e.g. IT |
| State  | State address of company e.g. WA |
| Locality  | City address of company e.g. Seattle |
| Country  | Country address of company e.g. USA |
| Email  | E-mail address of organizaion e.g. support@acme.com |
| CA Download  | http or https for downloading the minted certificates |
| Issuing CA  | FQDN\CA Name. e.g. cert3.acme.com\issuing | CA Name is the Name of the root of the CA Console on the issuing CA. |
| v6 Template  | Name of Template to use for all certificates. e.g. CertificateTemplate:vSphere6.0 |
| SubTemplate  | Name of Template to use for VCMA.| Not needed. |
| Root Renewal  | Renewal=0 | This is used to download the Root Certificate without requesting a renewal. |
| Subordinate Renewal 1  | Renewal=0 | This is used to download the 1st Intermediate Certificate without requesting a renewal. |
| Subordinate Renewal 2  | Renewal=0 | This is used to download the 2nd Intermediate Certificate without requesting a renewal. |
| vCenter | Which Node to use these certificate authority with. |
  
## clusters ##  
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| cluster name  | Cluster name string. |
| datacenter  | Datacenter you want that cluster to appear in. Valid values are 'all' or datacenter name. | Multiple DCs can be entered comma separated. |
| vCenter  | vCenter you want the cluster to appear in. Valid values are 'all' or vCenter FQDN. | Multiple VCs can be entered comma separated. |
  
## folders ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Name  | Folder name string. |
| Location  | Valid values include string names of existing folders or  name of datcenter, cluster, host, vApp, ResourcePool, vm. |
| Type  | Valid values: folder, datcenter, cluster, host, vApp, ResourcePool, vm |
| Datacenter  | All or datacenter name string you want the folder to appear in. | Multiple DCs can be entered comma separated.  |
| vCenter  | All or vCenter name string you want the folder to appear in. | Multiple VCs can be entered comma separated.  |
| Tier  | Values start at 1 for first layer in heirarchy, and incremeant by 1 for each level down. |
  
## licenses ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| vCenter | FQDN of vCenter you want to add the license to. |
| License Key | License key string. |
| Apply To | vCenter FQDN or Datacenter you want the License to apply to (needed for bulk licensing). | multiple DCs can be indicated by comma separation. |
| Type | Type of object you are applying the license to. DC = Datacenter, VC = Virtual Center. | Values can be separated by commas for multiple Apply to values. e.g. DC,DC,DC |
  
## permissions ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Entity | Name string of entity to put the permission. |
| Principal | Domain\Name string of account to apply permission to. |
| Group | TRUE/FALSE to is the Principal a Group (True) or User (false). |
| Propagate | TRUE/FALSE to propogate permission to child objects. |
| Role | vCenter Role to apply permission to. |
| vCenter | All or FQDN of vCenter to apply permission. | Multiple VCs can be entered comma separated.  |
  
## roles ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Name | Role name string. |
| Privilege | Valid vsphere privilege string e.g. Global.CancelTask. |
| vCenter | All or FQDN of vCenter.| Multiple VCs can be entered comma separated. |
  
## services ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| vCenter | All or FQDN of vCenter. |
| service | AuthProxy, AutoDeploy, NetDumpster, TFTP |
  
## sites ##
| Field | Valid values | Notes  |
| ----- | -------------- | ------ |
| Datacenter Name | Datacenter name string.| Multiple DCs can be entered comma separated.  |
| 1st Octet (oct1) | Valid ipv4 octet.| This value will replace oct1 in the network part of a vlan name, see vlan tab. |
| 2nd Octet (oct2) | Valid ipv4 octet.| This value will replace oct2 in the network part of a vlan name, see vlan tab. |
| 3rd Octet (oct3) | Valid ipv4 octet.|  This value will replace oct3 in the network part of a vlan name, see vlan tab. |
| vCenter | FQDN of vCenter.|
  
## vcsa ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Deploy? | first or deploy or null | Only use first for the first PSC in the environment. Can be used multiple times if separate environments are being deployed. |
| Config? | TRUE/FALSE| Configure this node? |
| Certs? | TRUE/FALSE| Replace Certificates? |
| vm name | Name string of node in vCenter. |
| hostname | Hostname string of node. |
| vcsa root password | String of root password to be set for node. |
| network mode | static/dynamic| dynamic has not been tested. |
| network family | ipv4/ipv6| ipv6 has not been tested. |
| network prefix | valid prefix e.g. 24 |
| jumbo frames | valid values TRUE/False |
| ip | valid ipv4 address for node. |
| gateway | valid ipv4 address of gateway. |
| dns | valid ipv4 address of dns server. |
| ntp | valid ipv4 address of ntp server. |
| enable ssh | True/False |
| diskmode | Valid diskmode see OVFTool 4.1 documentation. |
| deployment | Valid deployment type see OVFTool 4.1 documentation. |
| esxi host | esxi hostname or ipv4 address. |
| esxi network | Needs to be the portgroup name of a standard vswitch not vdswitch. |
| esxi datastore | Valid datastore name string. |
| esxi root user | esxi root username. e.g. root |
| esxi root password | esxi root userpassword string. |
| associated psc | null or fqdn name string of valid PSC. |
| sso domain name | Valid SSO domain name string. |
| sso site name | Valid SSO Site name string. |
| sso admin password | SSO Admin password string to set for node or used to connect to node. |
| ova name | Name string of the ova file to deploy the vcsa. |
  
## vdswitches ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Number | Starting at 1.0 and incrementing by 0.1, allows for 100 distributed switches. | Make sure to use a single quote for any number ending in zero (0) e.g. '1.0 |
| vDS Name | Name string of vdswitch |
| Datacenter | All or Name string of Datacenter. | Multiple DCs can be entered comma separated. |
| vCenter | All or FQDN of vCenter. | Multiple VCs can be entered comma separated. |
| Version | Any major vSphere release version e.g. 5.5.0, 6.0.0, 6.5.0 |
  
## vlans ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| number | first two numbers from left represent vdswitch, next two numbers are the portgroup e.g. 1.0.0.0 = vdswitch 1.0 portgroup 0.0 |
| vlan | vl ####, vx ####, Trunk  (vlan <number>, vxlan <number>, Trunk) |
| network | subnet/network prefix where oct1,2,3 represent octet replaced by that value from the site tab to reduce number of entries when multiple sites have the same vdswitch. |
| vlan  name | Name string of vlan which is combined with number and network to produce the name. e.g. 1.0.0.0 - vl 100 - 10.0.0.10/24 - vdi production |
| datacenter | Datacenter you want that cluster to appear in. Valid values are 'all' or datacenter name. | Multiple DCs can be entered comma separated. |
| vCenter | All or FQDN of vCenter. | Multiple VCs can be entered comma separated. |
  
## OS ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| OSType | Windows/Linux |
| Server | FQDN of vCenter. |
| Name | OS customization name string. |
| Type | NonPersistent/Persistent |
| DnsServer | ipv4 of DNS server. | Not Required. |
| DnsSuffix | DNS suffix name string. | Not Required. |
| Domain | Domain name string. |
| NamingScheme | Custom, Fixed, Prefix, VM | Not Required. |
| NamingPrefix | if using Prefix Naming Scheme. | Not Required. |
| Description | Description string. | Not Required. |
| Spec | Name string of existing OS Customization Spec. | Not Required. |
| FullName | Name string. |
| OrgName | Company name string. |
| ChangeSid | TRUE/FALSE| Windows Only. |
| DeleteAccounts | TRUE/FALSE| Delete user accounts. |
| GuiRunonce | List of commands to run once.| Not tested. |
| AdminPassword | Specify a new OS administrator's password. |
| TimeZone | Specify the name or ID of the time zone for the OS. The following time zones are available e.g. 035 or Eastern (U.S. and Canada) |
| AutoLogonCount | number - Specify the number of times the virtual machine automatically logs in as administrator without prompting for user credentials. |
| Workgroup | String  - 	Specify a workgroup. |
| DomainUsername | String - Specify the user name you want to use for domain authentication. |
| DomainPassword | String - Specify the password you want to use for domain authentication. |
| ProductKey | String - Specify the MS product key. If the guest OS version is earlier than Vista, this parameter is required in order to make the customization unattended. For Vista or later, the OS customization is unattended no matter if the ProductKey parameter is set |
| LicenseMode | Specify the license mode of the Windows 2000/2003 guest operating system. The valid values are Perseat, Perserver, and Notspecified. If Perserver is set, use the -LicenseMaxConnection parameter to define the maximum number of connections. |
| LicenseMaxConnections | Specify the maximum connections for server license mode. Use this parameter only if the -LicenseMode parameter is set to Perserver. |
  
## plugins ##
| Field | Valid values | Notes |
| ----- | -------------- | ------ |
| Server | FQDN of Node.| Multiple Servers can be entered comma separated. |
| Source Folder | Specify file(s) source folder string.  \subfolder under scripthome\subfolder e.g. \onyx |
| Destination Folder | Specify file(s) destination folder string. /root/.ssh |
| Source File(s) | either a filename or wildcard * |
| Command | command to run on the vcsa e.g. chmod 400 /root/.ssh/cert.crt | One command per line, cannot be on a line for a file copy. |

The new vCenter 6.5 environment is deployed via a powershell/powercli script that reads an excel file with all the configurations necessary to create a vSphere environment fully configured.

The script has three phases it could execute:
  - Deployment	- Deploys one or more VCSAs as a External PSC, vCenter Node, or Combined PSC/vCenter.
  - Certificate Creation and Replacement - Creates and replaces all relevant certificates for the specified nodes. **(Note: As a new feature, the script can be used to rotate all the certificates, replacing the ones that are already there).**
  - Configuration - Configure the following items: AD Domain Membership, AuthProxy, AutoDeploy, NetDumpster, TFTP, Folders, Clusters, vdswitches, vlans, Permissions, Roles, Datacenters, Host Profiles, OS Customizations, and Plugins.
  
  Each Phase can be enabled or disabled for each VCSA deployment. It is possible to run the script to do only one or two phases e.g. Deployment and Configuration or just Certificate Replacement etc.
  

## Requirements: ##

**Software:**
  - Powershell 4.0+									Available from vmware downloads
  - PowerCli 6.3+										Available from vmware downloads
  - OVFTool 4.1+										Available from vmware downloads
  - Microsoft Excel 2010+ (Note: only required if using Excel as a source instead of yaml or jason).
  - Win64OpenSSL_Light-1_1_0c.exe+		Available from http://slproweb.com/products/Win32OpenSSL.html - script will download and install if not detected.

**Other Requirements:**
  - Create DNS Entries for all VCSA deployments and their reverse lookup pointers.
  - VCSA OVA 6.5/6.7
  - Any Offline Bundle zip files for autodeploy specified in the excel sheet.
  - Exported Host Profile (needed if using autodeploy).
  - Any plugin files you intend the deployment to configure for you.
  - **The user account you are logged in with, needs permissions to mint certificates on the Certificate Authority**
  
**Remains to be tested:**
  - Deployment as one node PSC + vCenter on one node. - successfully tested.
  - Deployment using the VMCA instead of an external CA.

**Known Issues:**
  - Authproxy currently not working. VMware is aware of this and will have a fix with their next patch/release.
  - Script triggering Alarm is currently hard coded. In future will try to load from Excel.
  - Issue with deployment of configurations without certificate replacement. Need to Troubleshoot this.

Folder Structure of Script folder location:  
**`\<folder name>\`**  
Deploy VCSA to ESXi.ps1		- Required  
vsphere-config.xlsx		- Required if using Default configuration file. 
 
**`\<folder name>\Certs\<sso domain>\`**  
Root Certificate.cer				- Downloaded if not present. Not Required if not replacing certs.  
Intermediate Certificate.cer			- Downloaded if not present. Not Required if not replacing certs.  
Intermediate Certificate2.cer			- Downloaded if not present. Not Required if not replacing certs.  
SSH Certificate to connect to VCSA Nodes	- Will be created when script runs.

**`\<folder name>\json\`**  
Needed if using json as deployment configuration source. 
 - **ad-info.json**
 - **autodeploy-rules.json**
 - **cert-info.json**
 - **cluster-info.json**
 - **deployments.json**
 - **folders.json**
 - **licenses.json**
 - **os-customizations.json**
 - **permissions.json**
 - **plugins.json**
 - **roles.json**
 - **services.json**
 - **sites.json**
 - **summary.json**
 - **vdswitches.json**
 - **vlans.json**

**`\<folder name>\plugin	- Not required if no plugins to install.`**  

**`\<folder name>\yaml\`**  
Needed if using yaml as deployment configuration source. 
 - **ad-info.yml**
 - **autodeploy-rules.yml**
 - **cert-info.yml**
 - **cluster-info.yml**
 - **deployments.yml**
 - **folders.yml**
 - **licenses.yml**
 - **os-customizations.yml**
 - **permissions.yml**
 - **plugins.yml**
 - **roles.yml**
 - **services.yml**
 - **sites.yml**
 - **summary.yml**
 - **vdswitches.yml**
 - **vlans.yml**

 In phase 1, the script deploys the VCSA to an ESXi host. The target network needs to be on a **standard vswitch** (currently vdswitches are not supported).  
Once a VCSA is deployed, the script will wait until the VCSA has completed its firstboot configurations. This is checked by querying the VCSA to see if the '**/var/log/firstboot/succeeded**' file has been created.  

When deploying multiple VCSAs, the script parses and deploys them sequentially. This is required if all the VCSAs are part of the same SSO Domain. The first PSC needs to be up and running for the firstboot of the remaining nodes in the SSO Domain to succeeded.  

In phase 2, the script generates and replaces all the certificates for all the Nodes in the SSO domain. The process it goes through is detailed below. The Script automates everything starting at Downloading the Root Certificates. You still need to create the template manually.
  
**All Certificates must be base-64 encoded. It should only contain the certificate, not a full chain.**
Submit a certificate request by using a base-64-encoded CMC or PKCS #10 file, or submit a renewal request by using a base-64-encoded PKCS #7 file.
  
## Certificates: ##
  - Root64 - Root CA certificate
  - Interm64 - 1st Intermediate CA certificate (only required if it exists)
  - Interm264 - 2nd Intermediate CA certificate (only required if it exists)
  - Chain - Chain certificate. (only required if you have intermediate CAs.)
  - machine certificate - all nodes
  - VMDIR certificate - all nodes  
### Solution certificates ###
  - machine - no longer needed on vSphere 6.5 (now uses the machine certificate above)
  - vsphere-webclient - all nodes
  - vpxd - vcenter only
  - vpxd-extention - vcenter only

## Certificate Template ##

**vSphere 6.0 Certificate Template**

**Machine SSL and Solution User Certificates**

  - Login to your issuing CA and launch the Certificate Authority MMC snap-in.
  - Locate the Certificate Templates folder, right click, and select Manage.
  - Locate the “Web Server” template, right click, and duplicate it.
  - Click on the General tab and name it “vSphere6.0”.
  - Click on the Extension tab, click on Application Policies, then Edit. Remove Server Authentication and click OK.
  - Select Key Usage, then click on Edit. Check the box next to nonrepudiation and click OK.
  - Click on Subject name tab. Ensure that “Supply in the request” is selected.
  - Click on the Compatibility tab and ensure the Windows server 2003 is selected for both options. Even if you are running a newer CA, don’t select later CA options.
  - Close the Certificate Templates console window, right click on Certificate Templates, select New, then Certificate Template to Issue. Find the vSphere6.0 template and select it. Click OK

## Downloading the Root Certificates ##
  - Open a blank MMC, then add the Certificates snap-in for the Computer account.
  - Navigate to the “Intermediate Certification Authorities” folder and open the Certificates folder. If you don’t see your CAs there, poke around in the other folders until you find them.
  - Find the certificate authorities for your environment. Right click on each one, and export as a base-64 encoded x.509 certificate. Save the root certificate as **C:\certs\root64.cer**. 
    * Save the first subordinate certificate (if applicable) as **C:\certs\interm64.cer**.
    * If you have a second subordinate, save that certificate as **C:\certs\interm264.cer**.

## Create the Chain Certificate ##
Open notepad and paste in the certificates in the following order.
  1. 2nd Intermediate Root certificate. \<if it exists, otherwise skip to step 2\>
  1. 1st Intermediate Root certificate. \<if it exists, otherwise skip to step 3\>
  1. Root CA certificate.

## Create the CSR ##

[ req ]  
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
keyUsage = digitalSignature, keyEncipherment, nonRepudiation  
subjectAltName = IP:\<Node IP\>,DNS:\<FQDN\>,DNS:\<Hostname not FQDN\>  
  
[ req_distinguished_name ]  
countryName = US  
stateOrProvinceName = WA  
localityName = Seattle  
0.organizationName = \<Company Name\>  
organizationalUnitName = \<Department Name\>  
commonName = \<Node FQDN\> or \<Solution Cert e.g. machine + Node FQDN\>  
  
## Mint the Certificate ##
`certreq.exe -submit -attrib CertificateTemplate:vSphere6.0 -config <fqdn of issuing certificate authority>\<Certification Authority Name> -f <CSR File Path> <Certificate File Path>`

## Create the PEM File ##
open notepad and paste the entire contents of the .crt file in to it.  
paste the entire contents of the chain certificate file under it and save it as .cer  

## Copying the certificates to the node. ##

**Copy the following certificates to the node.**  
 
Destination on node for following files: **/root/ssl/**  
  - Root64.cer
  - Interm64.cer
  - Interm264.cer
  - chain.cer
 
Destination on node for following files: **/root/solutioncerts/**  
  - new_machine.cer
  - new_machine.priv
  - vsphere-webclient.cer
  - vsphere-webclient.priv
  - vpxd.cer
  - vpxd.priv
  - vpxd-extension.cer
  - vpxd-extension.priv
  - VMDir.cer
  - VMDir.priv
  
## Create a putty public/private key pair and copy it to the node. ##
  - Open PuttyGen.
  - Under parameters select SSH-2 RSA.
  - Change the Number of bits generated key to 2048.
  - Click Generate.
  - Wiggle the mouse until it finishes.
  - Click Save private key.
  - Click yes when saving the private key without a passphrase.
  - Save the file as **id_private.ppk**
  - Select all the characters in the Public key for pasting into OpenSSH authorized_keys file box.
  - Copy and save that in to a blank text document.
  - Save it as **id_vsphere.pub**  

Copy the id_vsphere.pub file to the node.  
  - Add the SSH Public Key to the authorized keys.
    * Create the .ssh folder. `mkdir /root/.ssh`
    * Set the .ssh folder permissions. `chmod 700 /root/.ssh`
    * Append the public certificate to the Authorized key file. 
      + `cat /root/ssl/id_vsphere.pub >> /root/.ssh/authorized_keys`
    * Change the Authorized key file permissions.
      + `chmod 600 /root/.ssh/authorized_keys`

**Stop all services**  
`service-control --stop --all`  
  
**Start vmafdd, vmdird, and vmca services.**  
  
`service-control --start vmafdd`  
`service-control --start vmdird`  
`service-control --start vmca`  
  
**Add your Trusted Root and all intermediate Certificates to the node.**  
  - Use dir-cli to change the VCSA root Certificates.
    * `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert /root/ssl/root64.cer`
    * `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert /root/ssl/interm64.cer`
    * `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert /root/ssl/interm264.cer`

  - Add certificate chain to TRUSTED_ROOTS of the PSC for ESXi Cert Replacement.  
    * `echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry create --store TRUSTED_ROOTS --alias chain.cer --cert /root/ssl/chain.cer`
  
  - Retrieve the current VCSA Machine Certificate and save the thumbprint to a file.
    * `/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store MACHINE_SSL_CERT --alias __MACHINE_CERT --output /root/ssl/old_machine.crt`
    * `openssl x509 -in /root/ssl/old_machine.crt -noout -sha1 -fingerprint > /root/ssl/thumbprint.txt`
  
  - Replace the machine cert with the CA Minted machine cert.  
	  * `echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store MACHINE_SSL_CERT --alias __MACHINE_CERT`
	  * `/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store MACHINE_SSL_CERT --alias __MACHINE_CERT --cert /root/ssl/new_machine.cer --key /root/ssl/ssl_key.priv`
  
  - Replace the vsphere-webclient solution certificate.  
	  * `echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vsphere-webclient --alias vsphere-webclient`
	  * `/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vsphere-webclient --alias vsphere-webclient --cert /root/solutioncerts/vsphere-webclient.cer --key /root/solutioncerts/vsphere-webclient.priv`

	- **Note:** As of vSphere 6.5, the machine Solution Certificate no longer needs to be replaced. The VCSA will use the Non-Solution machine Certificate instead.
		
  - Replace the vpxd solution certificate. - Not needed on external PSC.  
	  * `echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd --alias vpxd`
	  * `/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd --alias vpxd --cert /root/solutioncerts/vpxd.cer --key /root/solutioncerts/vpxd.priv`
	  
  - Replace the vpxd-extention solution certificate. - Not needed on external PSC.  
	  * `echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd-extension --alias vpxd-extension`
	  * `/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd-extension --alias vpxd-extension --cert /root/solutioncerts/vpxd-extension.cer --key /root/solutioncerts/vpxd-extension.priv`
 
## Updating the VCSA Solution Users. ##  
### Retrieve unique key list relevant to the server ###
   - **Get the machine id for the node:**  
      * `/usr/lib/vmware-vmafd/bin/vmafd-cli get-machine-id --server-name localhost`   
        + **d00f3abf-27f7-433b-96fb-ab7bba26273a**
  	
   - **Get the certificate list for the node:**  
      * `/usr/lib/vmware-vmafd/bin/dir-cli service list`
         + **machine-74e4fdb8-b9cc-4c14-b755-8a88cb1f5950**
         + **vsphere-webclient-74e4fdb8-b9cc-4c14-b755-8a88cb1f5950**
         + **machine-0e5c88d1-d418-4db6-9497-395fbb371b46**
         + **vsphere-webclient-0e5c88d1-d418-4db6-9497-395fbb371b46**
         + **machine-d00f3abf-27f7-433b-96fb-ab7bba26273a**
         + **vsphere-webclient-d00f3abf-27f7-433b-96fb-ab7bba26273a**
         + **vpxd-d00f3abf-27f7-433b-96fb-ab7bba26273a**
         + **vpxd-extension-d00f3abf-27f7-433b-96fb-ab7bba26273a**
         + **machine-1359447f-3884-44b8-87fe-f4467077edb5**
         + **vsphere-webclient-1359447f-3884-44b8-87fe-f4467077edb5**
         + **vpxd-1359447f-3884-44b8-87fe-f4467077edb5**
         + **vpxd-extension-1359447f-3884-44b8-87fe-f4467077edb5**
  
	  * Filter the returned list from the previous step, so that you only have the Solution Users for the local instance. e.g.
	    + Output should look like: 
		   - **machine-d00f3abf-27f7-433b-96fb-ab7bba26273a**
		   - **vsphere-webclient-d00f3abf-27f7-433b-96fb-ab7bba26273a**
		   - **vpxd-d00f3abf-27f7-433b-96fb-ab7bba26273a**
		   - **vpxd-extension-d00f3abf-27f7-433b-96fb-ab7bba26273a**
		
	  * Update the vsphere-webclient Solution User Certificate
	     + `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli service update --name vsphere-webclient-51269036-21f5-4f9d-af67-c9f047b71bd --cert /root/solutioncerts/vsphere-webclient.cer`
	  * **Note:** As of vSphere 6.5, the machine Solution Certificate no longer needs to be replaced. The VCSA will use the Non-Solution machine Certificate instead. 
	  * Update the vpxd Solution User Certificate  
	     + `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli service update --name vpxd-51269036-21f5-4f9d-af67-c9f047b71bda --cert /root/solutioncerts/vpxd.cer`
	  * Update the vpxd-extension Solution User Certificate
	     + `echo <SSOAdminPassword> | /usr/lib/vmware-vmafd/bin/dir-cli service update --name vpxd-extension-51269036-21f5-4f9d-af67-c9f047b71bda --cert /root/solutioncerts/vpxd-extension.cer`
	  * Start all services - `service-control --start --all --ignore`
  
## Replace EAM Solution User Cert - Only if not an external PSC. ##
  - Get the vpxd-extension Certificate
       * `/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.crt`
  - Get the vpxd-extension Certificate key
       * `/usr/lib/vmware-vmafd/bin/vecs-cli entry getkey --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.key`
  - Update the EAM Solution Certificate
       * `/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.vim.eam -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s <hostname> -u administrator@<SSODomainName> -p <SSOAdminPassword>`
  - Stop the vmware-eam service
       * `/usr/bin/service-control --stop vmware-eam`
  - Start the vmware-eam service
       * `/usr/bin/service-control --start vmware-eam`

  - Update VAMI Certs on External PSC
	  * `/usr/lib/applmgmt/support/scripts/postinstallscripts/setup-webserver.sh`
	
  - Refresh Update Manager Certificates.
	  * Refresh the Update Manager Certificates.
	     + `/usr/lib/vmware-updatemgr/bin/updatemgr-util refresh-certs`
      * Register the VC with Update Manager.
	     + `/usr/lib/vmware-updatemgr/bin/updatemgr-util register-vc`
	  
  - Register new certificates with VMWare Lookup Service - KB2121701 and KB2121689  
	  **Note:** In the command below, thumbprint is the bold text part of what you save in /root/ssl/thumbprint.txt above (the VC thumbprint).    
          If the output is: SHA1 Fingerprint=86:72:05:D6:4D:15:C5:31:3A:83:3A:02:A4:79:0C:5F:FB:AF:EE:7A    
          Then the thumbprint is: **86:72:05:D6:4D:15:C5:31:3A:83:3A:02:A4:79:0C:5F:FB:AF:EE:7A**  
    * `python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://<hostname>/lookupservice/sdk --fingerprint <thumbprint> --certfile /root/ssl/new_machine.crt --user administrator@<SSODomainName> --password <SSOAdminPassword>`
	
	- If the VCSA vCenter does not have an embedded PSC Register its Machine Certificate with the External PSC.
	  * SCP the new vCenter machine certificate to the external PSC and register it with the VMWare Lookup Service via SSH.
	  * Make a copy of the VC new_machine.crt and name it new_<VC_Hostname>_machine.crt.
	  * Copy new_<VC_Hostname>_machine.crt to the external PSC and place it in **/root/ssl/** folder.
	  * Update the lookup service certificate for the Virtual Center  
	    + `python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://<Psc_Hostname>/lookupservice/sdk --fingerprint <vc_thumbprint> --certfile /root/ssl/new_<vc_hostname>_machine.crt --user administrator@<SSODomainName> --password <SSOAdminPass>`
	  
5. Configure Autodeploy and replace the solution user certificates, and update the thumbprint to the new machine ssl thumbprint  
    https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988  
	- Configure Autodeploy to automatic start and start the service.
	  * Set the Autodeploy Start type.
	     + `/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC`
	  * Restart the Autodeploy Service.
	     + `/usr/lib/vmware-vmon/vmon-cli --restart rbd`
	- Replace the solution user cert for Autodeploy.
	  * `/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s <vc_hostname> -u administrator@<SSODomainName> -p <SSOAdminPass>`
	- Configure imagebuilder and start the service.
	  * Set the Imagebuilder Start type.
	     + `/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC`
	  * Restart the Imagebuilder Service.
	     + `/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder`
	- Replace the imagebuilder solution user cert.
	  * `/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.imagebuilder -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s <vc_hostname> -u administrator@<SSODomainName> -p <SSOAdminPass>`
	- Get the new machine cert thumbprint.
	  * `openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint`
	- Stop the autodeploy service  
      * `/usr/bin/service-control --stop vmware-rbd-watchdog`
	- Replace the autodeploy thumbprint  
      * `autodeploy-register -R -a <vc_Hostname> -u Administrator@<SSODomainName> -w <SSOAdminPass> -s "/etc/vmware-rbd/autodeploy-setup.xml" -f -T <new_thumbprint>`
	- Start the autodeploy service  
      * `/usr/bin/service-control --start vmware-rbd-watchdog`
		
6.	Replace VCSA Authorization Proxy Server Certificates
	- Create the VCSA Authorization Proxy Certificate CSR.
	- Mint the VCSA Authorization Proxy Certificate.
	- Copy the autproxy.crt to the VCSA in **/var/lib/vmware/vmcam/ssl/authproxy.crt**.
	- Copy the authproxy.priv private key to **/var/lib/vmware/vmcam/ssl/authproxy.key**.
	- Set the Authorization Proxy service starttype to Automatic  
       * `/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC`
	- Restart the Authorization Proxy service  
       * `/usr/lib/vmware-vmon/vmon-cli --restart vmcam`
	- Unregister the Authorization Proxy Server  
       * `/usr/lib/vmware-vmcam/bin/camregister --unregister -a <vc_hostname> -u Administrator@<SSODomainName> -p <SSOAdminPass>`
	- Stop the Authorization Proxy Service  
       * `/usr/bin/service-control --stop vmcam`
	- Backup the old Authorization Proxy Service Certificate  
       * `mv /var/lib/vmware/vmcam/ssl/rui.crt /var/lib/vmware/vmcam/ssl/rui.crt.bak`
	- Backup the old Authorization Proxy Service Certificate Key  
       * `mv /var/lib/vmware/vmcam/ssl/rui.key /var/lib/vmware/vmcam/ssl/rui.key.bak`
	- Rename the new Certificate for the Authorization Proxy  
       * `mv /var/lib/vmware/vmcam/ssl/authproxy.crt /var/lib/vmware/vmcam/ssl/rui.crt`
	- Rename the new Certificate key for the Authorization Proxy  
       * `mv /var/lib/vmware/vmcam/ssl/authproxy.key /var/lib/vmware/vmcam/ssl/rui.key`
	- Change the Authorization Proxy Certificate Permissions  
       * `chmod 600 /var/lib/vmware/vmcam/ssl/rui.cr`
	- Change the Authorization Proxy Certificate key Permissions  
       * `chmod 600 /var/lib/vmware/vmcam/ssl/rui.key`
	- Restart the Authorization Proxy service  
       * `/usr/lib/vmware-vmon/vmon-cli --restart vmcam`
	- Register the VC with the Authorization Proxy Service  
       * `/usr/lib/vmware-vmcam/bin/camregister --register -a <vc_hostname> -u Administrator@<SSODomainName> -p <SSOAdminPass> -c /var/lib/vmware/vmcam/ssl/rui.crt -k /var/lib/vmware/vmcam/ssl/rui.key`

The configuration phase takes care of the following tasks:  
  
  - Join a Node (PSC/vCenter) to the Windows Domain.
  - If Node is the first node in the SSO Domain:
    * Add AD domain as Native Identity Source.
    * Add AD vCenter Admins to Component Administrators SSO Group.
    * Add AD vCenter Admins to License Administrators SSO Group.
    * Add AD vCenter Admins to Administrators SSO Group.
    * Add AD vCenter Admins to Certificate Authority Administrators SSO Group.
    * Add AD vCenter Admins to Users SSO Group.
    * Add AD vCenter Admins to System Configuration Administrators SSO Group.

**vCenter Only**
  - Creates Datacenters.
  - Creates Folders.
  - Creates Roles.
  - Assigns Permissions.
  - Adds OS Customizations.
  - Creates Clusters.
  - Creates vdswitches.
  - Creates Portgroups on vdswitches.
  - Sets up multi-nic vmotion.
  - Adds and assigns licenses for vCenters.
  - Adds VMHost licenses and assigns bulk licensing.
  - Configures Auth Proxy. [currently not fuctional due to vmware bug.]
  - Configures Auo Deploy.
  - Configures Network Dump Collector.
  - Configures TFTP.
  - Can load and install plugins or run additional commands.
