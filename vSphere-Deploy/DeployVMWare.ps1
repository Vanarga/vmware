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

    1.  Derek Seamans            - www.derekseaman.com
    2.  William Lam                - www.virtuallyghetto.com
    3.  Chris Greene            - orchestration.io
    4.  RJ Davis                - community.whatsupgold.com
    5.  Joel "Jaykul" Bennett     - huddledmasses.org/
    6.  Francois-Xavier Cat     - www.lazywinadmin.com/
    7.  Friedrich Eva            - www.kanap.net/
    8.  Andrea Casin            - myvirtualife.net
    9.  Sam McGeown                - www.definit.co.uk
    10. Wojciech Marusiak        - wojcieh.net
    11. blog.cloudinfra.info
    12. F�idhlim O'Leary        - haveyoutriedreinstalling.com
    13. Alan Renouf                - www.virtu-al.net
    14. Jeramiah Dooley            - Netapp
    15. Aaron Patten            - Netapp
    16. VMWare Support
    17. John Dwyer                - grokthecloud.com
    18. Rob Bastiaansen         - www.vmwarebits.com
    19. Luc Deneks                - communities.vmware.com/people/LucD and www.lucd.info
    20. Brian Graf                - www.vtagion.com
    21. Mark Brookfield            - vitualhobbit.com
    22. Eric Gray                - blogs.vmware.com
    23. Christopher Lewis        - thecloudxpert.net
    24. Dave Wyatt                - StackOverflow

.AUTHOR
    Michael van Blijdesteijn
    Last Updated: 10-24-2019
#>

# Check to see if the url is Get-URLStatus.
Param (
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("excel","json","yaml")]
        [string]$Source = "excel",
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [switch]$Export,
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string]$FilePath
)

# Get public and private function definition files.
$certFunctions  = @( Get-ChildItem -Path "$PSScriptRoot\Certificates\*.ps1" -ErrorAction SilentlyContinue)
$privateFunctions = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue)

# Dot source the files
ForEach ($import in @($certFunctions + $privateFunctions))
{
    Try {
        Write-Verbose -Message "Importing $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Clear the screen.
Clear-Host

Try {
    Add-Type -AssemblyName Microsoft.Office.Interop.Excel -ErrorAction SilentlyContinue
}
Catch {
    Add-Type -LiteralPath $((Get-ChildItem -Path "C:\Windows\assembly\GAC_MSIL\Microsoft.Office.Interop.Excel\*" -Recurse).FullName)
}
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook
$excelFileName = "vsphere-configs.xlsx"

if (-not $FilePath) {
    $folderPath = $pwd.path.ToString()
} else {
    $FilePath = Root-Path -Path $FilePath
}

if ($Source -eq "excel" -and $FilePath) {
    $excelFileName  = $FilePath.Split("\")[$FilePath.Split("\").count -1]
    $folderPath     = $FilePath.Substring(0,$FilePath.Lastindexof("\"))
}

# PSScriptRoot does not have a trailing "\"
Write-Output -InputObject $folderPath | Out-String

# Start New Transcript
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Continue"
$logPath = "$folderPath\Logs\" + $(Get-Date -Format "MM-dd-yyyy_HH-mm")
if (-not(Test-Path -Path $logPath)) {
    New-Item -Path $logPath -Type Directory
}
$OutputPath = "$logPath\InitialState_" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
Start-Transcript -Path $OutputPath -Append

Write-SeparatorLine

# Check to see if Powershell is at least version 3.0
if (-not($host.Version.major -gt 3)) {
    Write-Host -Object "PowerShell 3.0 or higher required. Please install"; Exit
}

# Load Modules
Load-Module -ModuleName "VMware.PowerCLI"
Load-Module -ModuleName "PowerShell-Yaml"

Write-SeparatorLine

# Check the version of Ovftool and get it's path. Search C:\program files\ and C:\Program Files (x86)\ subfolders for vmware and find the
# Ovftool folders. Then check the version and return the first one that is version 4 or higher.
$OvfToolPath = (Get-ChildItem -Path (Get-ChildItem -Path $env:ProgramFiles, ${env:ProgramFiles(x86)} -Filter vmware).Fullname -Recurse -Filter ovftool.exe | `
    ForEach-Object {
        if (-not((& $($_.DirectoryName + "\ovftool.exe") --version).Split(" ")[2] -lt 4.0.0))
            {$_}
    } | Select-Object -First 1).DirectoryName

# Check ovftool version
if (-not $OvfToolPath) {
    Write-Host -Object "Script requires installation of ovftool 4.0.0 or newer";
    exit
} else {
    Write-Host -Object "ovftool version OK `r`n"
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
            $configData = Import-JsonData -Path $Json_Dir
    }

    'yaml' {
            $Yaml_Dir = $folderPath + "\Yaml"
            $configData = Import-YamlData -Path $Yaml_Dir
    }
}

$configData | ForEach-Object {
    Write-Output -InputObject $_ | Out-String
    Write-SeparatorLine
}

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
if ($Source -ne "excel" -and $Export.IsPresent) {
    $ExcelFilePathDst = "$folderPath\$excelFileName"
    if (Test-Path -Path $ExcelFilePathDst) {
        Remove-Item -Path $ExcelFilePathDst -Confirm:$false -Force
    }

    $ObjExcelDst = New-Object -ComObject Excel.Application
    $ObjExcelDst.Visible = $false
    $WorkBookDst = $ObjExcelDst.Workbooks.Add()
    $WorkSheetcount = 16 - ($WorkBookDst.worksheets | Measure-Object).Count

    # http://www.planetcobalt.net/sdb/vba2psh.shtml
    $def = [Type]::Missing
    $null = $ObjExcelDst.Worksheets.Add($def,$def,$WorkSheetcount,$def)

    $sheetNum = (3..1) + (4..16) | ForEach-Object {"Sheet$_"}
    for ($i=0;$i -lt 16;$i++) {
        $params = @{
            InputObject = $configData.($configData.GetEnumerator().Name[$i])
            Worksheet = Get-WorkSheet -Workbook $WorkBookDst -SheetName $sheetNum[$i]
            SheetName = $configData.GetEnumerator().Name[$i]
            Excelpath = $ExcelFilePathDst
        }
        Write-Output -InputObject $params | Out-String
        ConvertTo-Excel @params
    }

    $ObjExcelDst.DisplayAlerts = $False
    $ObjExcelDst.ActiveWorkbook.SaveAs($ExcelFilePathDst,$xlFixedFormat)
    $WorkBookDst.Close($false)
    $ObjExcelDst.Quit()

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($WorkBookDst)
    [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ObjExcelDst)
}

### Save to Json
if ($Source -ne "json" -and $Export.IsPresent) {
    if (-not(Test-Path -Path "$folderPath\Json")) {
        New-Item -Path "$folderPath\Json" -Type Directory
    }
    $configData.GetEnumerator() | ForEach-Object {
        Save-Json -InputObject $_ -FilePath "$folderPath\json\$($_.Key).json"
    }
}

### Save to Yaml
if ($Source -ne "yaml" -and $Export.IsPresent) {
    if (-not(Test-Path -Path "$folderPath\Yaml")) {
        New-Item -Path "$folderPath\Yaml" -Type Directory
    }

    # Change commas to ":" Colon for Vlan Network Properties.
    for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
        $configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ",",':'; $_.value = $commacorrect}}
    }

    $configData.GetEnumerator() | ForEach-Object {
        Save-Yaml -InputObject $_ -FilePath "$folderPath\yaml\$($_.Key).yml"
    }

    # Change ":" Colon to commas for Vlan Network Properties.
    for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
        $configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commacorrect = $_.value -replace ":",','; $_.value = $commacorrect}}
    }

}

# Replace "<null>" placeholder with actual $null.
$configData.GetEnumerator() | ForEach-Object {
    Add-Null -InputObject $_.Value
}

# ---------------------  END Load Parameters from Excel ------------------------------

# Check to see if OpenSSL is installed, install it otherwise.
Install-OpenSSL

Write-SeparatorLine

Skip-SSLTrustIssues

# Certificate variables
# Create the RANDFILE environmental parameter for openssl to fuction properly.
$env:RANDFILE = "$folderPath\Certs\.rnd"

$script:CertsWaitingForApproval = $false
New-Alias -Name OpenSSL -Value $OpenSSL

Stop-Transcript

# Deploy the VCSA servers.
ForEach ($Deployment in $configData.Deployments | Where-Object {$_.Action}) {
    # Skip deployment if set to null.

    $OutputPath = "$logPath\Deploy-" + $Deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $OutputPath -Append

    Write-Output -InputObject "=============== Starting deployment of $($Deployment.vmName) ===============" | Out-String

    # Deploy the vcsa
    $params = @{
        ParameterList = $Deployment
        OvfToolPath = $OvfToolPath
        LogPath = $logPath
    }
    New-VCSADeploy @params

    # Write separator line to transcript.
    Write-SeparatorLine

    # Create esxi credentials.
    $ESXiSecPasswd = $null
    $ESXiCreds = $null
    $ESXiSecPasswd = ConvertTo-SecureString -String $Deployment.esxiRootPass -AsPlainText -Force
    $ESXiCreds = New-Object -TypeName System.Management.Automation.PSCredential($Deployment.esxiRootUser, $ESXiSecPasswd)

    # Connect to esxi host of the deployed vcsa.
    $params = @{
        Server = $Deployment.esxiHost
        Credential = $ESXiCreds
    }
    $ESXiHandle = Connect-VIServer @params

    Write-SeparatorLine

    Write-Output -InputObject "== Firstboot process could take 10+ minutes to complete. please wait. ==" | Out-String

    if (-not $StopWatch) {
        $StopWatch =  [system.diagnostics.stopwatch]::StartNew()
    } else {
        $StopWatch.start()
    }

    $VCSACredential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))
    $params = @{
        Script = 'find /var/log/firstboot/ -type f \( -name "succeeded" -o -name "failed" \)'
        Hostname = $Deployment.Hostname
        Credential = $VCSACredential
        ViHandle = $ESXiHandle
    }
    $Firstboot = (Invoke-ExecuteScript @params).ScriptOutput

    While (-not $Firstboot) {

        Start-Sleep -Seconds 15

        $Elapsed = $StopWatch.Elapsed.ToString('hh\:mm\:ss')

        Write-Progress -Activity "Completing Firstboot for $($Deployment.Hostname)" -Status "Time Elapsed $Elapsed"

        Write-Output -InputObject "Time Elapsed completing Firstboot for $($Deployment.Hostname): $Elapsed" | Out-String

        $params = @{
            Script = $script
            Hostname = $Deployment.Hostname
            Credential = $VCSACredential
            ViHandle = $ESXiHandle
        }
        $Firstboot = (Invoke-ExecuteScript @params).ScriptOutput
    }

    $StopWatch.reset()

    if ($Firstboot -like "*failed*") {
        Write-Output -InputObject "Deployment of " + $Deployment.Hostname + " Failed. Exiting Script." | Out-String
        break
    }

    # Enable Jumbo Frames on eth0 if True.
    if ($Deployment.JumboFrames) {
        $commandList = $null
        $commandList = @()
        $commandList += 'echo -e "" >> /etc/systemd/network/10-eth0.network'
        $commandList += 'echo -e "[Link]" >> /etc/systemd/network/10-eth0.network'
        $commandList += 'echo -e "MTUBytes=9000" >> /etc/systemd/network/10-eth0.network'

        $params = @{
            Script = $commandList
            Hostname = $Deployment.vmName
            Credential = $VCSACredential
            ViHandle = $ESXiHandle
        }
        Invoke-ExecuteScript @params
    }

    Write-Output -InputObject "`r`n The VCSA $($Deployment.Hostname) has been deployed and is Get-URLStatus.`r`n" | Out-String

    # Create certificate directory if it does not exist
    $CertDir = $folderPath + "\Certs\" + $Deployment.SSODomainName
    $DefaultRootCertDir = $CertDir + "\" + $Deployment.Hostname + "\DefaultRootCert"

    if (-not(Test-Path -Path $DefaultRootCertDir)) {
        New-Item -Path $DefaultRootCertDir -Type Directory | Out-Null
    }

    Write-Host -Object "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String
    $params = @{
        CertDir = $CertDir
        Deployment = $Deployment
        VIHandle = $ESXiHandle
    }
    New-CertificatePair @params

    # Import the vCenter self signed certificate into the local trusted root certificate store.
    $params = @{
        CertPath = $DefaultRootCertDir
        Deployment = $Deployment
        VIHandle = $ESXiHandle
    }
    Import-HostRootCertificate @params
    # Disconnect from the vcsa deployed esxi server.
    Disconnect-VIServer -Server $ESXiHandle -Confirm:$false

    # Write separator line to transcript.
    Write-SeparatorLine

    Write-Host -Object "=============== End of Deployment for $($Deployment.vmName) ===============" | Out-String

    Stop-Transcript
}

# Replace Certificates.
ForEach ($Deployment in $configData.Deployments| Where-Object {$_.Certs}) {

    $OutputPath = "$logPath\Certs-" + $Deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $OutputPath -Append

    Write-Output -InputObject "=============== Starting replacement of Certs on $($Deployment.vmName) ===============" | Out-String

    # Wait until the vcsa is Get-URLStatus.
    $params = @{
        URL = "https://" + $Deployment.Hostname
    }
    Get-URLStatus @params

    # Set $CertDir
    $CertDir = $folderPath + "\Certs\" + $Deployment.SSODomainName
    $RootCertDir = $CertDir + "\" + $Deployment.Hostname

    # Create certificate directory if it does not exist
    if (-not(Test-Path -Path $RootCertDir)) {
        New-Item -Path $RootCertDir -Type Directory | Out-Null
    }

    $configData.Certs = $configData.CertInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}

    Write-Output -InputObject $configData.Certs | Out-String

    if ($configData.Certs) {
        # Create esxi credentials.
        $ESXiSecPasswd = $null
        $ESXiCreds = $null
        $ESXiSecPasswd = ConvertTo-SecureString -String $Deployment.esxiRootPass -AsPlainText -Force
        $ESXiCreds = New-Object -TypeName System.Management.Automation.PSCredential($Deployment.esxiRootUser, $ESXiSecPasswd)

        # Connect to esxi host of the deployed vcsa.
        $ESXiHandle = Connect-VIServer -Server $Deployment.esxiHost -Credential $ESXiCreds

        # Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
        $configData.Certs.CompanyName = $Deployment.Hostname

        # $InstanceCertDir is the script location plus cert folder and Hostname eg. C:\Script\Certs\SSODomain\vm-host1.companyname.com\
        $InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

        # Check for or download root certificates.
        $params = @{
            CertDir = $RootCertDir
            CertInfo = $configData.Certs
        }
        Import-RootCertificate @params

        # Create the Machine cert.
        $params = @{
            SVCDir = "machine"
            CSRName = "machine_ssl.csr"
            CFGName = "machine_ssl.cfg"
            PrivFile = "ssl_key.priv"
            Flag = 6
            CertDir = $InstanceCertDir
            CertInfo = $configData.Certs
        }
        New-CSR @params
        $params = @{
            SVCDir = "machine"
            CSRFile = "machine_ssl.csr"
            CertFile = "new_machine.crt"
            Template = $configData.Certs.V6Template
            CertDir = $InstanceCertDir
            IssuingCA = $configData.Certs.IssuingCA
        }
        Invoke-CertificateMint @params
        $params = @{
            SVCDir = "machine"
            CertFile = "new_machine.crt"
            CerFile = "new_machine.cer"
            CertDir = $RootCertDir
            InstanceCertDir = $InstanceCertDir
        }
        ConvertTo-PEMFormat @params

        # Change back to the script root folder.
        Set-Location -Path $folderPath

        # Create the VMDir cert.
        $params = @{
            SVCDir = "VMDir"
            CSRName = "VMDir.csr"
            CFGName = "VMDir.cfg"
            PrivFile = "VMDir.priv"
            Flag = 6
            CertDir = $InstanceCertDir
            CertInfo = $configData.Certs
        }
        New-CSR @params
        $params = @{
            SVCDir = "VMDir"
            CSRFile = "VMDir.csr"
            CertFile = "VMDir.crt"
            Template = $configData.Certs.V6Template
            CertDir = $InstanceCertDir
            IssuingCA = $configData.Certs.IssuingCA
        }
        Invoke-CertificateMint @params
        $params = @{
            SVCDir = "VMDir"
            CertFile = "VMDir.crt"
            CerFile = "VMDir.cer"
            CertDir = $RootCertDir
            InstanceCertDir = $InstanceCertDir
        }
        ConvertTo-PEMFormat @params

        # Rename the VMDir cert for use on a VMSA.
        Rename-VMDir -CertDir $InstanceCertDir

        # Change back to the script root folder.
        Set-Location -Path $folderPath

        $SSOParent = $null
        $SSOParent = $configData.Deployments | Where-Object {$Deployment.Parent -eq $_.Hostname}

        # Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
        if ($Deployment.DeployType -eq "infrastructure") {
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "machine.csr"
                $CFGName = "machine.cfg"
                $PrivFile = "machine.priv"
                $Flag = 6
                $SolutionUser = "machine"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "vsphere-webclient.csr"
                $CFGName = "vsphere-webclient.cfg"
                $PrivFile = "vsphere-webclient.priv"
                $Flag = 6
                $SolutionUser = "vsphere-webclient"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "machine.csr"
                CertFile = "machine.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "vsphere-webclient.csr"
                CertFile = "vsphere-webclient.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "machine.crt"
                CerFile = "machine.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "vsphere-webclient.crt"
                CerFile = "vsphere-webclient.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params

            Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            $params = @{
                RootCertDir = $RootCertDir
                CertDir = $CertDir
                Deployment = $Deployment
                VIHandle = $ESXiHandle
                DeploymentParent = $SSOParent
            }
            Copy-CertificateToHost @params
        } else {
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "vpxd.csr"
                $CFGName = "vpxd.cfg"
                $PrivFile = "vpxd.priv"
                $Flag = 6
                $SolutionUser = "vpxd"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "vpxd-extension.csr"
                $CFGName = "vpxd-extension.cfg"
                $PrivFile = "vpxd-extension.priv"
                $Flag = 6
                $SolutionUser = "vpxd-extension"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "machine.csr"
                $CFGName = "machine.cfg"
                $PrivFile = "machine.priv"
                $Flag = 6
                $SolutionUser = "machine"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                $SVCDir = "Solution"
                $CSRName = "vsphere-webclient.csr"
                $CFGName = "vsphere-webclient.cfg"
                $PrivFile = "vsphere-webclient.priv"
                $Flag = 6
                $SolutionUser = "vsphere-webclient"
                $CertDir = $InstanceCertDir
                $Certinfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "vpxd.csr"
                CertFile = "vpxd.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "vpxd-extension.csr"
                CertFile = "vpxd-extension.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "machine.csr"
                CertFile = "machine.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CSRFile = "vsphere-webclient.csr"
                CertFile = "vsphere-webclient.crt"
                Template = $configData.Certs.V6Template
                CertDir = $InstanceCertDir
                IssuingCA = $configData.Certs.IssuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "vpxd.crt"
                CerFile = "vpxd.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "vpxd-extension.crt"
                CerFile = "vpxd-extension.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "machine.crt"
                CerFile = "machine.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params
            $params = @{
                SVCDir = "Solution"
                CertFile = "vsphere-webclient.crt"
                CerFile = "vsphere-webclient.cer"
                CertDir = $RootCertDir
                InstanceCertDir = $InstanceCertDir
            }
            ConvertTo-PEMFormat @params

            Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            $params = @{
                RootCertDir = $RootCertDir
                CertDir = $CertDir
                Deployment = $Deployment
                VIHandle = $ESXiHandle
                DeploymentParent = $SSOParent
            }
            Copy-CertificateToHost @params
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

                $params = @{
                    Script = $commandList
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    ViHandle = $ESXiHandle
                }
                Invoke-ExecuteScript @params

                # Get the new machine cert thumbprint.
                $commandList = $null
                $commandList = @()
                $commandList += "openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint"

                $params = @{
                    Script = $commandList
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    ViHandle = $ESXiHandle
                }
                $newthumbprint = $(Invoke-ExecuteScript @params).Scriptoutput.Split("=",2)[1]
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
                $params = @{
                    Script = $commandList
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    ViHandle = $ESXiHandle
                }
                Invoke-ExecuteScript @params
            }
            if (($configData.Services | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and $_.Service -eq "AuthProxy"}).Service) {
                # Create Authorization Proxy Server Certificates.
                $params = @{
                    SVCDir = "authproxy"
                    CSRName = "authproxy.csr"
                    CFGName = "authproxy.cfg"
                    PrivFile = "authproxy.priv"
                    Flag = 6
                    CertDir = $InstanceCertDir
                    CertInfo = $configData.Certs
                }
                New-CSR @params
                $params = @{
                    SVCDir = "authproxy"
                    CSRFile = "authproxy.csr"
                    CertFile = "authproxy.crt"
                    Template = $configData.Certs.V6Template
                    CertDir = $InstanceCertDir
                    IssuingCA = $configData.Certs.IssuingCA
                }
                Invoke-CertificateMint @params
                # Copy the Authorization Proxy Certs to the vCenter.
                $FileLocations = $null
                $FileLocations = @()
                $FileLocations += "$InstanceCertDir\authproxy\authproxy.priv"
                $FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.key"
                $FileLocations += "$InstanceCertDir\authproxy\authproxy.crt"
                $FileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.crt"
                $params = @{
                    Path = $FileLocations
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    VIHandle = $VIHandle
                    Upload = $true
                }
                Copy-FileToServer @params
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
                $params = @{
                    Script = $commandList
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    ViHandle = $ESXiHandle
                }
                Invoke-ExecuteScript @params
            }
        }

        Write-SeparatorLine

        Write-Host -Object "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String
        $params = @{
            CertDir = $CertDir
            Deployment = $Deployment
            VIHandle = $ESXiHandle
        }
        New-CertificatePair @params

        # Write separator line to transcript.
        Write-SeparatorLine

        # Delete all certificate files etc to clean up /root/ - exclude authorized_keys
        $commandList = $null
        $commandList = @()
        $commandList += 'rm /root/vcrootcert.crt'
        $commandList += 'rm -r /root/solutioncerts'
        $commandList += 'rm -r /root/ssl'
        $commandList += 'find /root/.ssh/ ! -name "authorized_keys" -type f -exec rm -rf {} \;'
        $params = @{
            Script = $commandList
            Hostname = $Deployment.Hostname
            Credential = $VCSACredential
            ViHandle = $ESXiHandle
        }
        Invoke-ExecuteScript @params

        Write-Host -Object "=============== Restarting $($Deployment.vmName) ===============" | Out-String
        $params = @{
            VM = $Deployment.vmName
            Server = $ESXiHandle
            Confirm = $false
        }
        Restart-VMGuest @params

        # Wait until the vcsa is Get-URLStatus.
        $params = @{
            URL = "https://" + $Deployment.Hostname
        }
        Get-URLStatus @params

        Write-Host -Object "=============== End of Certificate Replacement for $($Deployment.vmName) ===============" | Out-String

        # Disconnect from the vcsa deployed esxi server.
        $params = @{
            Server = $ESXiHandle
            Confirm = $false
        }
        Disconnect-VIServer @params
    }
    Stop-Transcript
}

# Configure the vcsa.
ForEach ($Deployment in $configData.Deployments| Where-Object {$_.Config}) {

    $OutputPath = "$logPath\Config-" + $Deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $OutputPath -Append

    # Set $CertDir
    $CertDir = $folderPath + "\Certs\" + $Deployment.SSODomainName
    $RootCertDir = $CertDir + "\" + $Deployment.Hostname

    # Create certificate directory if it does not exist
    if (-not(Test-Path -Path $RootCertDir)) {
        New-Item -Path $RootCertDir -Type Directory | Out-Null
    }

    Write-Output -InputObject "=============== Starting configuration of $($Deployment.vmName) ===============" | Out-String

    Write-SeparatorLine

    # Wait until the vcsa is Get-URLStatus.
    $params = @{
        URL = "https://" + $Deployment.Hostname
    }
    Get-URLStatus @params

    # Create esxi credentials.
    $ESXiSecPasswd = $null
    $ESXiCreds = $null
    $ESXiSecPasswd = ConvertTo-SecureString -String $Deployment.esxiRootPass -AsPlainText -Force
    $ESXiCreds = New-Object -TypeName System.Management.Automation.PSCredential($Deployment.esxiRootUser, $ESXiSecPasswd)

    # Connect to esxi host of the deployed vcsa.
    $params = @{
        Server = $Deployment.esxiHost
        Credential = $ESXiCreds
    }
    $ESXiHandle = Connect-VIServer @params

    Write-Host -Object "=============== Configure Certificate pair on $($Deployment.vmName) ===============" | Out-String
    $params = @{
        CertDir = $CertDir
        Deployment = $Deployment
        VIHandle = $ESXiHandle
    }
    New-CertificatePair @params

    Write-SeparatorLine

    Write-Output -InputObject $($configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($Deployment.Hostname)"}) | Out-String

    # Join the vcsa to the windows domain.
    $params = @{
        Deployment = $Deployment
        ADinfo = $configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($Deployment.Hostname)"}
        VIHandle = $ESXiHandle
    }
    Join-ADDomain @params

    # if the vcsa is not a stand alone PSC, configure the vCenter.
    if ($Deployment.DeployType -ne "infrastructure") {

        Write-Output -InputObject "== vCenter $($Deployment.vmName) configuration ==" | Out-String

        Write-SeparatorLine

        $Datacenters = $configData.Sites | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
        $SSOSecPasswd = ConvertTo-SecureString -String $($Deployment.SSOAdminPass) -AsPlainText -Force
        $SSOCreds = New-Object -TypeName System.Management.Automation.PSCredential ($("Administrator@" + $Deployment.SSODomainName), $SSOSecPasswd)

        # Connect to the vCenter
        $params = @{
            Server = $Deployment.Hostname
            Credential = $SSOCreds
        }
        $VCHandle = Connect-VIServer @params

        # Create Datacenter
        if ($Datacenters) {
            $Datacenters.Datacenter.ToUpper() | ForEach-Object {New-Datacenter -Location Datacenters -Name $_}
        }

        # Create Folders, Roles, and Permissions.
        $Folders = $configData.Folders | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"}
        if ($Folders) {
            Write-Output -InputObject "Folders:" $Folders
            $params = @{
                Folder = $Folders
                VIHandle = $VIHandle
            }
            New-Folders @params
        }

        # if this is the first vCenter, create custom Roles.
        $existingroles = Get-VIRole -Server $VCHandle
        $Roles = $configData.Roles | Where-Object {$_.vcenter.Split(",") -match "all|$($Deployment.Hostname)"} | Where-Object {$ExistingRoles -notcontains $_.Name}
           if ($Roles) {
            Write-Output -InputObject "Roles:" $Roles
            $params = @{
                Roles = $Roles
                VIHandle = $VCHandle
            }
            Add-Roles @params
        }

        # Create OS Customizations for the vCenter.
        $configData.OSCustomizations | Where-Object {$_.vCenter -eq $Deployment.Hostname} | ForEach-Object {ConvertTo-OSString -InputObject $_}

        # Create Clusters
        ForEach ($Datacenter in $Datacenters) {
            # Define IP Octets
            $Octet1 = $Datacenter.octet1
            $Octet2 = $Datacenter.octet2
            $Octet3 = $Datacenter.octet3

            # Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
               ($configData.Clusters | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)")`
                   -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}).Clustername |`
                ForEach-Object {if ($_) {New-Cluster -Location (Get-Datacenter -Server $VCHandle -Name $Datacenter.Datacenter) -Name $_}}

            # Create New vDSwitch
            # Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
            $VDSwitches = $configData.VDSwitches | Where-Object {($_.vCenter.Split(",") -match "all|$($Deployment.Hostname)") -and ($_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)")}

            ForEach ($VDSwitch in $VDSwitches) {
                $SwitchDatacenter = Get-Inventory -Name $Datacenter.Datacenter

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
                $params = @{
                    Server = $VCHandle
                    Name = $SwitchName
                    Location = $SwitchDatacenter
                    Mtu = $mtu
                    NumUplinkPorts = 2
                    Version = $VDSwitch.Version
                }
                New-VDSwitch @params

                # Enable NIOC
                $params = @{
                    Server = $VCHandle
                    Name = $SwitchName
                }
                (Get-vDSwitch @params | Get-View).EnableNetworkResourceManagement($true)

                $VLANAdd = $configData.VLANS | Where-Object {$_.Number.StartsWith($SwitchName.Split(" ")[0])}
                $VLANAdd = $VLANAdd | Where-Object {$_.Datacenter.Split(",") -match "all|$($Datacenter.Datacenter)"}
                $VLANAdd = $VLANAdd | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

                # Create Portgroups
                ForEach ($VLAN in $VLANAdd) {

                    $PortGroup = $VLAN.Number.padright(8," ") +`
                                 $VLAN.Vlan.padright(8," ") + "- " +`
                                 $VLAN.Network.padright(19," ") + "- " +`
                                 $VLAN.VlanName

                    $PortGroup = $PortGroup -replace "octet1", $Octet1
                    $PortGroup = $PortGroup -replace "octet2", $Octet2
                    $PortGroup = $PortGroup -replace "octet2", $Octet3

                    if ($PortGroup.Split("-")[0] -like "*trunk*") {
                        $params = @{
                            Server = $VCHandle
                            VDSwitch = $SwitchName
                            Name = $PortGroup
                            Notes = $PortGroup.Split("-")[0]
                            VlanTrunkRange = $VLAN.network
                        }
                        New-VDPortgroup @params
                    } else {
                        $params = @{
                            Server = $VCHandle
                            VDSwitch = $SwitchName
                            Name = $PortGroup
                            Notes = $PortGroup.Split("-")[1]
                        }
                        New-VDPortgroup @params
                    }
                    # Set Portgroup Team policies
                    if ($PortGroup -like "*vmotion-1*") {
                        Get-vdportgroup -Server $VCHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $VCHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
                    }
                    if ($PortGroup -like "*vmotion-2*") {
                        Get-vdportgroup -Server $VCHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $VCHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
                    }
                    if ($PortGroup -notlike "*vmotion*") {
                        Get-vdportgroup -Server $VCHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $VCHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
                    } else {
                        #Set Traffic Shaping on vmotion portgroups for egress traffic
                        Get-VDPortgroup -Server $VCHandle -VDSwitch $SwitchName | `
                            Where-Object {$_.Name.Split('%')[0] -like $PortGroup.Split('/')[0]} | `
                            Get-VDTrafficShapingPolicy -Server $VCHandle -Direction Out | `
                            Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
                    }
                }
            }
        }

        # Add Licenses to vCenter.
        if ($configData.Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) {
            Add-Licensing -Licenses $($configData.Licenses | Where-Object {$_.vCenter -eq $Deployment.Hostname}) -VIHandle $VCHandle
        }

        # Select permissions for all vCenters or the current vCenter.
        # Create the permissions.
        $params = @{
            VPermissions = $configData.Permissions | Where-Object {$_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}
            VIHandle = $VCHandle
        }
        New-Permissions @params

        $InstanceCertDir = $CertDir + "\" + $Deployment.Hostname

        # Configure Additional Services (Network Dump, Autodeploy, TFTP)
        ForEach ($Serv in $configData.Services) {
            Write-Output -InputObject $Serv | Out-String
            if ($Serv.vCenter.Split(",") -match "all|$($Deployment.Hostname)") {
                switch ($Serv.Service) {
                    AuthProxy {
                        $params = {
                            Deployment = $Deployment
                            VIHandle = $ESXiHandle
                            ADDomain = $configData.ADInfo | Where-Object {$_.vCenter -match "all|$($Deployment.Hostname)"}
                        }
                        New-AuthProxyService @params
                        break
                    }
                    AutoDeploy {
                        $VCHandle | Get-AdvancedSetting -Name vpxd.certmgmt.certs.minutesBefore | Set-AdvancedSetting -Value 1 -Confirm:$false
                        $params = @{
                            Deployment = $Deployment
                            VIHandle = $ESXiHandle
                        }
                        New-AutoDeployService @params
                        if ($configData.AutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}) {
                            $params = @{
                                Rules = $configData.AutoDepRules | Where-Object {$_.vCenter -eq $Deployment.Hostname}
                                Path = $folderPath
                                VIHandle = $VCHandle
                            }
                            New-AutoDeployRule @params
                        }
                        break
                    }
                    Netdumpster {
                        $params = @{
                            Hostname = $Deployment.Hostname
                            Credential = $VCSACredential
                            VIHandle = $ESXiHandle
                        }
                        New-NetDumpsterService @params
                        break
                    }
                    TFTP {
                        $params = @{
                            Hostname = $Deployment.Hostname
                            Credential = $VCSACredential
                            VIHandle = $ESXiHandle
                        }
                        New-TFTPService @params
                        break
                    }
                    default {
                        break
                    }
                }
            }
        }

        # Configure plugins
        $commandList = $null
        $commandList = @()
        $Plugins = $configData.Plugins | Where-Object {$_.config -and $_.vCenter.Split(",") -match "all|$($Deployment.Hostname)"}

        Write-SeparatorLine
        Write-Output -InputObject $Plugins | Out-String
        Write-SeparatorLine

        for ($i=0;$i -lt $Plugins.Count;$i++) {
            if ($Plugins[$i].SourceDir) {
                if ($commandList) {
                    $params = @{
                        Script = $commandList
                        Hostname = $Deployment.Hostname
                        Credential = $VCSACredential
                        ViHandle = $ESXiHandle
                    }
                    Invoke-ExecuteScript @params
                    $commandList = $null
                    $commandList = @()
                }
                $FileLocations = $null
                $FileLocations = @()
                $FileLocations += "$($folderPath)\$($Plugins[$i].SourceDir)\$($Plugins[$i].SourceFiles)"
                $FileLocations += $Plugins[$i].DestDir
                Write-Output -InputObject $FileLocations | Out-String
                $params = @{
                    Path = $FileLocations
                    Hostname = $Deployment.Hostname
                    Credential = $VCSACredential
                    VIHandle = $VIHandle
                    Upload = $true
                }
                Copy-FileToServer @params
            }
            if ($Plugins[$i].Command) {
                $commandList += $Plugins[$i].Command
            }
        }

        if ($commandList) {
            $params = @{
                Script = $commandList
                Hostname = $Deployment.Hostname
                Credential = $VCSACredential
                ViHandle = $ESXiHandle
            }
            Invoke-ExecuteScript @params
        }

        Write-SeparatorLine

        Write-Output -InputObject "Adding Build Cluster Alarm" | Out-String

        $DC = $Deployment.Hostname.Split(".")[1]

        $AlarmMgr = Get-View AlarmManager
        $entity = Get-Datacenter -Name $DC -Server $VCHandle | Get-Cluster -Name "build" | Get-View

        # AlarmSpec
        $Alarm = New-Object -TypeName VMware.Vim.AlarmSpec
        $Alarm.Name = "1. Configure New Esxi Host"
        $Alarm.Description = "Configure a New Esxi Host added to the vCenter"
        $Alarm.Enabled = $TRUE

        $Alarm.action = New-Object -TypeName VMware.Vim.GroupAlarmAction

        $Trigger = New-Object -TypeName VMware.Vim.AlarmTriggeringAction
        $Trigger.action = New-Object VMware.Vim.RunScriptAction
        $Trigger.action.Script = "/root/esxconf.sh {targetName}"

        # Transition a - yellow --> red
        $Transa = New-Object -TypeName VMware.Vim.AlarmTriggeringActionTransitionSpec
        $Transa.StartState = "yellow"
        $Transa.FinalState = "red"

        $Trigger.TransitionSpecs = $Transa

        $Alarm.action = $Trigger

        $Expression = New-Object -TypeName VMware.Vim.EventAlarmExpression
        $Expression.EventType = "EventEx"
        $Expression.eventTypeId = "vim.event.HostConnectedEvent"
        $Expression.objectType = "HostSystem"
        $Expression.status = "red"

        $Alarm.expression = New-Object -TypeName VMware.Vim.OrAlarmExpression
        $Alarm.expression.expression = $Expression

        $Alarm.setting = New-Object -TypeName VMware.Vim.AlarmSetting
        $Alarm.setting.reportingFrequency = 0
        $Alarm.setting.toleranceRange = 0

        # Create alarm.
        $AlarmMgr.CreateAlarm($entity.MoRef, $Alarm)

        # Disconnect from the vCenter.
        $params = @{
            Server = $VCHandle
            Confirm = $false
        }
        Disconnect-VIServer @params

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
        $params = @{
            Script = $commandList
            Hostname = $Deployment.Hostname
            Credential = $VCSACredential
            ViHandle = $ESXiHandle
        }
        Invoke-ExecuteScript @params
    }

    # Disconnect from the vcsa deployed esxi server.
    $params = @{
        Server = $ESXiHandle
        Confirm = $false
    }
    Disconnect-VIServer @params

    Write-SeparatorLine

    Write-Host -Object "=============== End of Configuration for $($Deployment.vmName) ===============" | Out-String

    Stop-Transcript
}

Write-SeparatorLine

Write-Output -InputObject "<=============== Deployment Complete ===============>" | Out-String

Set-Location -Path $folderPath

# Get Certificate folders that do not have a Date/Time in their name.
$CertFolders = (Get-Childitem -Path $($folderPath + "\Certs") -Directory).FullName | Where-Object {$_ -notmatch '\d\d-\d\d-\d\d\d\d'}

# Rename the folders to add Date/Time to the name.
$CertFolders | ForEach-Object {
    Rename-Item -Path $_ -NewName $($_ + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm"))
}

# Scrub logfiles
$LogFiles = (Get-ChildItem -Path $logPath).FullName

if ($configData.Summary.TranscriptScrub) {
    ForEach ($Log in $LogFiles) {
        $Transcript = Get-Content -Path $Log
        ForEach ($Pass in $Scrub) {
            $Transcript = $Transcript.replace($Pass,'<-- Password Redacted -->')
        }
        $Transcript | Set-Content -Path $Log -Force -Confirm:$false
    }
}