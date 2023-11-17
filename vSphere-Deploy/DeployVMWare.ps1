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
        [string]$source = "excel",
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [switch]$export,
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string]$filePath
)

# Get public and private function definition files.
$certFunctions  = @( Get-ChildItem -Path "$PSScriptRoot\Certificates\*.ps1" -ErrorAction SilentlyContinue)
$privateFunctions = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue)

# Dot source the files
ForEach ($import in @($certFunctions + $privateFunctions))
{
    Try {
        Write-Verbose -Message "Importing $($import.FullName)"
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

if (-not $filePath) {
    $folderPath = $pwd.path.ToString()
} else {
    $filePath = Root-Path -Path $filePath
}

if ($source -eq "excel" -and $filePath) {
    $excelFileName  = $filePath.Split("\")[$filePath.Split("\").count -1]
    $folderPath     = $filePath.Substring(0,$filePath.Lastindexof("\"))
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
$outputPath = "$logPath\InitialState_" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
Start-Transcript -Path $outputPath -Append

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
$ovfToolPath = (Get-ChildItem -Path (Get-ChildItem -Path $env:ProgramFiles, ${env:ProgramFiles(x86)} -Filter vmware).Fullname -Recurse -Filter ovftool.exe | `
    ForEach-Object {
        if (-not((& $($_.DirectoryName + "\ovftool.exe") --version).Split(" ")[2] -lt 4.0.0))
            {$_}
    } | Select-Object -First 1).DirectoryName

# Check ovftool version
if (-not $ovfToolPath) {
    Write-Host -Object "Script requires installation of ovftool 4.0.0 or newer";
    exit
} else {
    Write-Host -Object "ovftool version OK `r`n"
}

# ---------------------  Load Parameters from Excel ------------------------------

### Load from Excel
switch ($source) {
    'excel' {
            Import-Module -Name pwshExcel
            # Source Excel Path
            $excelFilePathSrc = "$folderPath\$excelFileName"
            $configData = Import-ExcelData -Path $excelFilePathSrc
    }

    'json' {
            $jsonPath = $folderPath + "\Json"
            $configData = Import-JsonData -Path $jsonPath
    }

    'yaml' {
            $yamlPath = $folderPath + "\Yaml"
            $configData = Import-YamlData -Path $yamlPath
    }
}

$configData | ForEach-Object {
    Write-Output -InputObject $_ | Out-String
    Write-SeparatorLine
}

# Password Scrub array for redacting passwords from Transcript.
if ($configData.Summary.TranscriptScrub) {
    $scrub = @()
    $scrub += $configData.ADInfo.ADJoinPass
    $scrub += $configData.ADInfo.ADvmcamPass
    $scrub += $configData.AutoDepRules.ProfileRootPassword
    $scrub += $configData.OSCustomizations.AdminPassword
    $scrub += $configData.OSCustomizations.DomainPassword
    $scrub += $configData.Deployments.VCSARootPass
    $scrub += $configData.Deployments.esxiRootPass
    $scrub += $configData.Deployments.SSOAdminPass
}

### Save to Excel
if ($source -ne "excel" -and $export.IsPresent) {
    $excelFilePathDst = "$folderPath\$excelFileName"
    if (Test-Path -Path $excelFilePathDst) {
        Remove-Item -Path $excelFilePathDst -Confirm:$false -Force
    }

    $objExcelDst = New-Object -ComObject Excel.Application
    $objExcelDst.Visible = $false
    $workbookDst = $objExcelDst.Workbooks.Add()
    $worksheetCount = 16 - ($workbookDst.worksheets | Measure-Object).Count

    # http://www.planetcobalt.net/sdb/vba2psh.shtml
    $def = [Type]::Missing
    $null = $objExcelDst.Worksheets.Add($def,$def,$worksheetCount,$def)

    $sheetNum = (3..1) + (4..16) | ForEach-Object {"Sheet$_"}
    for ($i=0;$i -lt 16;$i++) {
        $params = @{
            inputObject = $configData.($configData.GetEnumerator().Name[$i])
            worksheet = Get-WorkSheet -Workbook $workbookDst -SheetName $sheetNum[$i]
            sheetName = $configData.GetEnumerator().Name[$i]
            excelPath = $excelFilePathDst
        }
        Write-Output -InputObject $params | Out-String
        ConvertTo-Excel @params
    }

    $objExcelDst.DisplayAlerts = $False
    $objExcelDst.ActiveWorkbook.SaveAs($excelFilePathDst,$xlFixedFormat)
    $workbookDst.Close($false)
    $objExcelDst.Quit()

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workbookDst)
    [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($objExcelDst)
}

### Save to Json
if ($source -ne "json" -and $export.IsPresent) {
    if (-not(Test-Path -Path "$folderPath\Json")) {
        New-Item -Path "$folderPath\Json" -Type Directory
    }
    $configData.GetEnumerator() | ForEach-Object {
        Save-Json -InputObject $_ -filePath "$folderPath\json\$($_.Key).json"
    }
}

### Save to Yaml
if ($source -ne "yaml" -and $export.IsPresent) {
    if (-not(Test-Path -Path "$folderPath\Yaml")) {
        New-Item -Path "$folderPath\Yaml" -Type Directory
    }

    # Change commas to ":" Colon for Vlan Network Properties.
    for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
        $configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commaCorrect = $_.value -replace ",",':'; $_.value = $commaCorrect}}
    }

    $configData.GetEnumerator() | ForEach-Object {
        Save-Yaml -InputObject $_ -filePath "$folderPath\yaml\$($_.Key).yml"
    }

    # Change ":" Colon to commas for Vlan Network Properties.
    for ($i=0;$i -lt ($configData.VLANS | Measure-Object).count;$i++) {
        $configData.VLANS[$i].psobject.properties | Where-Object {if ($_.name -eq "network") {$commaCorrect = $_.value -replace ":",','; $_.value = $commaCorrect}}
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
ForEach ($deployment in $configData.Deployments | Where-Object {$_.Action}) {
    # Skip deployment if set to null.

    $outputPath = "$logPath\Deploy-" + $deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $outputPath -Append

    Write-Output -InputObject "=============== Starting deployment of $($deployment.vmName) ===============" | Out-String

    # Deploy the vcsa
    $params = @{
        parameterList = $deployment
        ovfToolPath = $ovfToolPath
        logPath = $logPath
    }
    New-VCSADeploy @params

    # Write separator line to transcript.
    Write-SeparatorLine

    # Create esxi credentials.
    $esxiSecPasswd = $null
    $esxiCreds = $null
    $esxiSecPasswd = ConvertTo-SecureString -String $deployment.esxiRootPass -AsPlainText -Force
    $esxiCreds = New-Object -TypeName System.Management.Automation.PSCredential($deployment.esxiRootUser, $esxiSecPasswd)

    # Connect to esxi host of the deployed vcsa.
    $params = @{
        server = $deployment.esxiHost
        credential = $esxiCreds
    }
    $esxiHandle = Connect-VIServer @params

    Write-SeparatorLine

    Write-Output -InputObject "== Firstboot process could take 10+ minutes to complete. please wait. ==" | Out-String

    if (-not $stopWatch) {
        $stopWatch =  [system.diagnostics.stopwatch]::StartNew()
    } else {
        $stopWatch.start()
    }

    $vcsaCredential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $deployment.VCSARootPass -AsPlainText -Force))
    $params = @{
        script = 'find /var/log/firstboot/ -type f \( -name "succeeded" -o -name "failed" \)'
        hostname = $deployment.Hostname
        credential = $vcsaCredential
        viHandle = $esxiHandle
    }
    $firstBoot = (Invoke-ExecuteScript @params).ScriptOutput

    While (-not $firstBoot) {

        Start-Sleep -Seconds 15

        $elapsed = $stopWatch.Elapsed.ToString('hh\:mm\:ss')

        Write-Progress -Activity "Completing Firstboot for $($deployment.Hostname)" -Status "Time Elapsed $elapsed"

        Write-Output -InputObject "Time Elapsed completing Firstboot for $($deployment.Hostname): $elapsed" | Out-String

        $params = @{
            script = $script
            hostname = $deployment.Hostname
            credential = $vcsaCredential
            viHandle = $esxiHandle
        }
        $firstBoot = (Invoke-ExecuteScript @params).ScriptOutput
    }

    $stopWatch.reset()

    if ($firstBoot -like "*failed*") {
        Write-Output -InputObject "Deployment of " + $deployment.Hostname + " Failed. Exiting Script." | Out-String
        break
    }

    # Enable Jumbo Frames on eth0 if True.
    if ($deployment.JumboFrames) {
        $commandList = $null
        $commandList = @()
        $commandList += 'echo -e "" >> /etc/systemd/network/10-eth0.network'
        $commandList += 'echo -e "[Link]" >> /etc/systemd/network/10-eth0.network'
        $commandList += 'echo -e "MTUBytes=9000" >> /etc/systemd/network/10-eth0.network'

        $params = @{
            script = $commandList
            hostname = $deployment.vmName
            credential = $vcsaCredential
            viHandle = $esxiHandle
        }
        Invoke-ExecuteScript @params
    }

    Write-Output -InputObject "`r`n The VCSA $($deployment.Hostname) has been deployed and is Get-URLStatus.`r`n" | Out-String

    # Create certificate directory if it does not exist
    $certPath = $folderPath + "\Certs\" + $deployment.SSODomainName
    $defaultRootCertPath = $certPath + "\" + $deployment.Hostname + "\DefaultRootCert"

    if (-not(Test-Path -Path $defaultRootCertPath)) {
        New-Item -Path $defaultRootCertPath -Type Directory | Out-Null
    }

    Write-Host -Object "=============== Configure Certificate pair on $($deployment.vmName) ===============" | Out-String
    $params = @{
        certPath = $certPath
        deployment = $deployment
        viHandle = $esxiHandle
    }
    New-CertificatePair @params

    # Import the vCenter self signed certificate into the local trusted root certificate store.
    $params = @{
        certPath = $defaultRootCertPath
        deployment = $deployment
        viHandle = $esxiHandle
    }
    Import-HostRootCertificate @params
    # Disconnect from the vcsa deployed esxi server.
    Disconnect-VIServer -Server $esxiHandle -Confirm:$false

    # Write separator line to transcript.
    Write-SeparatorLine

    Write-Host -Object "=============== End of Deployment for $($deployment.vmName) ===============" | Out-String

    Stop-Transcript
}

# Replace Certificates.
ForEach ($deployment in $configData.Deployments| Where-Object {$_.Certs}) {

    $outputPath = "$logPath\Certs-" + $deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $outputPath -Append

    Write-Output -InputObject "=============== Starting replacement of Certs on $($deployment.vmName) ===============" | Out-String

    # Wait until the vcsa is Get-URLStatus.
    $params = @{
        url = "https://" + $deployment.Hostname
    }
    Get-URLStatus @params

    # Set $certPath
    $certPath = $folderPath + "\Certs\" + $deployment.SSODomainName
    $rootCertPath = $certPath + "\" + $deployment.Hostname

    # Create certificate directory if it does not exist
    if (-not(Test-Path -Path $rootCertPath)) {
        New-Item -Path $rootCertPath -Type Directory | Out-Null
    }

    $configData.Certs = $configData.certInfo | Where-Object {$_.vCenter -match "all|$($deployment.Hostname)"}

    Write-Output -InputObject $configData.Certs | Out-String

    if ($configData.Certs) {
        # Create esxi credentials.
        $esxiSecPasswd = $null
        $esxiCreds = $null
        $esxiSecPasswd = ConvertTo-SecureString -String $deployment.esxiRootPass -AsPlainText -Force
        $esxiCreds = New-Object -TypeName System.Management.Automation.PSCredential($deployment.esxiRootUser, $esxiSecPasswd)

        # Connect to esxi host of the deployed vcsa.
        $esxiHandle = Connect-VIServer -Server $deployment.esxiHost -Credential $esxiCreds

        # Change the Placeholder (FQDN) from the certs tab to the FQDN of the vcsa.
        $configData.Certs.CompanyName = $deployment.Hostname

        # $instanceCertPath is the script location plus cert folder and Hostname eg. C:\Script\Certs\SSODomain\vm-host1.companyname.com\
        $instanceCertPath = $certPath + "\" + $deployment.Hostname

        # Check for or download root certificates.
        $params = @{
            certPath = $rootCertPath
            certInfo = $configData.Certs
        }
        Import-RootCertificate @params

        # Create the Machine cert.
        $params = @{
            servicePath = "machine"
            csrFilename = "machine_ssl.csr"
            configName = "machine_ssl.cfg"
            privFile = "ssl_key.priv"
            flag = 6
            certPath = $instanceCertPath
            certInfo = $configData.Certs
        }
        New-CSR @params
        $params = @{
            servicePath = "machine"
            csrFile = "machine_ssl.csr"
            certFile = "new_machine.crt"
            template = $configData.Certs.V6template
            certPath = $instanceCertPath
            issuingCA = $configData.Certs.issuingCA
        }
        Invoke-CertificateMint @params
        $params = @{
            servicePath = "machine"
            certFile = "new_machine.crt"
            cerFile = "new_machine.cer"
            certPath = $rootCertPath
            instanceCertPath = $instanceCertPath
        }
        ConvertTo-PEMFormat @params

        # Change back to the script root folder.
        Set-Location -Path $folderPath

        # Create the VMDir cert.
        $params = @{
            servicePath = "VMDir"
            csrFilename = "VMDir.csr"
            configName = "VMDir.cfg"
            privFile = "VMDir.priv"
            flag = 6
            certPath = $instanceCertPath
            certInfo = $configData.Certs
        }
        New-CSR @params
        $params = @{
            servicePath = "VMDir"
            csrFile = "VMDir.csr"
            certFile = "VMDir.crt"
            template = $configData.Certs.V6template
            certPath = $instanceCertPath
            issuingCA = $configData.Certs.issuingCA
        }
        Invoke-CertificateMint @params
        $params = @{
            servicePath = "VMDir"
            certFile = "VMDir.crt"
            cerFile = "VMDir.cer"
            certPath = $rootCertPath
            instanceCertPath = $instanceCertPath
        }
        ConvertTo-PEMFormat @params

        # Rename the VMDir cert for use on a VMSA.
        Rename-VMDir -CertPath $instanceCertPath

        # Change back to the script root folder.
        Set-Location -Path $folderPath

        $ssoParent = $null
        $ssoParent = $configData.Deployments | Where-Object {$deployment.Parent -eq $_.Hostname}

        # Create the Solution User Certs - 2 for External PSC, 4 for all other deployments.
        if ($deployment.DeployType -eq "infrastructure") {
            $params = @{
                servicePath = "Solution"
                csrFilename = "machine.csr"
                configName = "machine.cfg"
                privFile = "machine.priv"
                flag = 6
                solutionUser = "machine"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFilename = "vsphere-webclient.csr"
                configName = "vsphere-webclient.cfg"
                privFile = "vsphere-webclient.priv"
                flag = 6
                solutionUser = "vsphere-webclient"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFile = "machine.csr"
                certFile = "machine.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                csrFile = "vsphere-webclient.csr"
                certFile = "vsphere-webclient.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                certFile = "machine.crt"
                cerFile = "machine.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params
            $params = @{
                servicePath = "Solution"
                certFile = "vsphere-webclient.crt"
                cerFile = "vsphere-webclient.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params

            Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            $params = @{
                rootcertPath = $rootCertPath
                certPath = $certPath
                deployment = $deployment
                viHandle = $esxiHandle
                deploymentParent = $ssoParent
            }
            Copy-CertificateToHost @params
        } else {
            $params = @{
                servicePath = "Solution"
                csrFilename = "vpxd.csr"
                configName = "vpxd.cfg"
                privFile = "vpxd.priv"
                flag = 6
                solutionUser = "vpxd"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFilename = "vpxd-extension.csr"
                configName = "vpxd-extension.cfg"
                privFile = "vpxd-extension.priv"
                flag = 6
                solutionUser = "vpxd-extension"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFilename = "machine.csr"
                configName = "machine.cfg"
                privFile = "machine.priv"
                flag = 6
                solutionUser = "machine"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFilename = "vsphere-webclient.csr"
                configName = "vsphere-webclient.cfg"
                privFile = "vsphere-webclient.priv"
                flag = 6
                solutionUser = "vsphere-webclient"
                certPath = $instanceCertPath
                certInfo = $configData.Certs
            }
            New-SolutionCSR @params
            $params = @{
                servicePath = "Solution"
                csrFile = "vpxd.csr"
                certFile = "vpxd.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                csrFile = "vpxd-extension.csr"
                certFile = "vpxd-extension.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                csrFile = "machine.csr"
                certFile = "machine.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                csrFile = "vsphere-webclient.csr"
                CertFile = "vsphere-webclient.crt"
                template = $configData.Certs.V6template
                certPath = $instanceCertPath
                issuingCA = $configData.Certs.issuingCA
            }
            Invoke-CertificateMint @params
            $params = @{
                servicePath = "Solution"
                certFile = "vpxd.crt"
                cerFile = "vpxd.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params
            $params = @{
                servicePath = "Solution"
                certFile = "vpxd-extension.crt"
                cerFile = "vpxd-extension.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params
            $params = @{
                servicePath = "Solution"
                certFile = "machine.crt"
                cerFile = "machine.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params
            $params = @{
                servicePath = "Solution"
                certFile = "vsphere-webclient.crt"
                cerFile = "vsphere-webclient.cer"
                certPath = $rootCertPath
                instanceCertPath = $instanceCertPath
            }
            ConvertTo-PEMFormat @params

            Write-SeparatorLine
            # Copy Cert files to vcsa Node and deploy them.
            $params = @{
                rootCertPath = $rootCertPath
                certPath = $certPath
                deployment = $deployment
                viHandle = $esxiHandle
                deploymentParent = $ssoParent
            }
            Copy-CertificateToHost @params
            # Configure Autodeploy and replace the solution user certificates, and update the thumbprint to the new machine ssl thumbprint.
            # https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2000988
            if (($configData.Services | Where-Object {($_.vCenter.Split(",") -match "all|$($deployment.Hostname)") -and $_.Service -eq "AutoDeploy"}).Service) {
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
                $commandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.rbd -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($deployment.Hostname) -u administrator@$($deployment.SSODomainName) -p `'$($deployment.SSOAdminPass)`'"
                # Configure imagebuilder and start the service.
                $commandList += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
                $commandList += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"
                # Replace the imagebuilder solution user cert.
                $commandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.imagebuilder -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s $($deployment.Hostname) -u administrator@$($deployment.SSODomainName) -p `'$($deployment.SSOAdminPass)`'"

                $params = @{
                    script = $commandList
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    viHandle = $esxiHandle
                }
                Invoke-ExecuteScript @params

                # Get the new machine cert thumbprint.
                $commandList = $null
                $commandList = @()
                $commandList += "openssl x509 -in /root/ssl/new_machine.crt -noout -sha1 -fingerprint"

                $params = @{
                    script = $commandList
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    viHandle = $esxiHandle
                }
                $newThumbprint = $(Invoke-ExecuteScript @params).Scriptoutput.Split("=",2)[1]
                $newThumbprint = $newThumbprint -replace "`t|`n|`r",""
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
                $commandList += "autodeploy-register -R -a " + $deployment.Hostname + " -u Administrator@" + $deployment.SSODomainName + " -w `'" + $deployment.SSOAdminPass + "`' -s `"/etc/vmware-rbd/autodeploy-setup.xml`" -f -T $newThumbprint"
                # Start the autodeploy service.
                $commandList += "/usr/bin/service-control --start vmware-rbd-watchdog"
                $params = @{
                    script = $commandList
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    viHandle = $esxiHandle
                }
                Invoke-ExecuteScript @params
            }
            if (($configData.Services | Where-Object {($_.vCenter.Split(",") -match "all|$($deployment.Hostname)") -and $_.Service -eq "AuthProxy"}).Service) {
                # Create Authorization Proxy Server Certificates.
                $params = @{
                    servicePath = "authproxy"
                    csrFilename = "authproxy.csr"
                    configName = "authproxy.cfg"
                    privFile = "authproxy.priv"
                    flag = 6
                    certPath = $instanceCertPath
                    certInfo = $configData.Certs
                }
                New-CSR @params
                $params = @{
                    servicePath = "authproxy"
                    csrFile = "authproxy.csr"
                    certFile = "authproxy.crt"
                    template = $configData.Certs.V6template
                    certPath = $instanceCertPath
                    issuingCA = $configData.Certs.issuingCA
                }
                Invoke-CertificateMint @params
                # Copy the Authorization Proxy Certs to the vCenter.
                $fileLocations = $null
                $fileLocations = @()
                $fileLocations += "$instanceCertPath\authproxy\authproxy.priv"
                $fileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.key"
                $fileLocations += "$instanceCertPath\authproxy\authproxy.crt"
                $fileLocations += "/var/lib/vmware/vmcam/ssl/authproxy.crt"
                $params = @{
                    path = $fileLocations
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    viHandle = $viHandle
                    upload = $true
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
                $commandList += "/usr/lib/vmware-vmcam/bin/camregister --unregister -a " + $deployment.Hostname + " -u Administrator@" + $deployment.SSODomainName + " -p `'" + $deployment.SSOAdminPass + "`'"
                $commandList += "/usr/bin/service-control --stop vmcam"
                $commandList += "mv /var/lib/vmware/vmcam/ssl/rui.crt /var/lib/vmware/vmcam/ssl/rui.crt.bak"
                $commandList += "mv /var/lib/vmware/vmcam/ssl/rui.key /var/lib/vmware/vmcam/ssl/rui.key.bak"
                $commandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.crt /var/lib/vmware/vmcam/ssl/rui.crt"
                $commandList += "mv /var/lib/vmware/vmcam/ssl/authproxy.key /var/lib/vmware/vmcam/ssl/rui.key"
                $commandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.crt"
                $commandList += "chmod 600 /var/lib/vmware/vmcam/ssl/rui.key"
                $commandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
                $commandList += "/usr/lib/vmware-vmcam/bin/camregister --register -a " + $deployment.Hostname + " -u Administrator@" + $deployment.SSODomainName + " -p `'" + $deployment.SSOAdminPass + "`' -c /var/lib/vmware/vmcam/ssl/rui.crt -k /var/lib/vmware/vmcam/ssl/rui.key"
                # Service update
                $params = @{
                    script = $commandList
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    viHandle = $esxiHandle
                }
                Invoke-ExecuteScript @params
            }
        }

        Write-SeparatorLine

        Write-Host -Object "=============== Configure Certificate pair on $($deployment.vmName) ===============" | Out-String
        $params = @{
            certPath = $certPath
            deployment = $deployment
            viHandle = $esxiHandle
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
            script = $commandList
            hostname = $deployment.Hostname
            credential = $vcsaCredential
            viHandle = $esxiHandle
        }
        Invoke-ExecuteScript @params

        Write-Host -Object "=============== Restarting $($deployment.vmName) ===============" | Out-String
        $params = @{
            vm = $deployment.vmName
            server = $esxiHandle
            confirm = $false
        }
        Restart-VMGuest @params

        # Wait until the vcsa is Get-URLStatus.
        $params = @{
            url = "https://" + $deployment.Hostname
        }
        Get-URLStatus @params

        Write-Host -Object "=============== End of Certificate Replacement for $($deployment.vmName) ===============" | Out-String

        # Disconnect from the vcsa deployed esxi server.
        $params = @{
            server = $esxiHandle
            confirm = $false
        }
        Disconnect-VIServer @params
    }
    Stop-Transcript
}

# Configure the vcsa.
ForEach ($deployment in $configData.Deployments| Where-Object {$_.Config}) {

    $outputPath = "$logPath\Config-" + $deployment.Hostname + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm") + ".log"
    Start-Transcript -Path $outputPath -Append

    # Set $certPath
    $certPath = $folderPath + "\Certs\" + $deployment.SSODomainName
    $rootCertPath = $certPath + "\" + $deployment.Hostname

    # Create certificate directory if it does not exist
    if (-not(Test-Path -Path $rootCertPath)) {
        New-Item -Path $rootCertPath -Type Directory | Out-Null
    }

    Write-Output -InputObject "=============== Starting configuration of $($deployment.vmName) ===============" | Out-String

    Write-SeparatorLine

    # Wait until the vcsa is Get-URLStatus.
    $params = @{
        url = "https://" + $deployment.Hostname
    }
    Get-URLStatus @params

    # Create esxi credentials.
    $esxiSecPasswd = $null
    $esxiCreds = $null
    $esxiSecPasswd = ConvertTo-SecureString -String $deployment.esxiRootPass -AsPlainText -Force
    $esxiCreds = New-Object -TypeName System.Management.Automation.PSCredential($deployment.esxiRootUser, $esxiSecPasswd)

    # Connect to esxi host of the deployed vcsa.
    $params = @{
        server = $deployment.esxiHost
        credential = $esxiCreds
    }
    $esxiHandle = Connect-VIServer @params

    Write-Host -Object "=============== Configure Certificate pair on $($deployment.vmName) ===============" | Out-String
    $params = @{
        certPath = $certPath
        deployment = $deployment
        viHandle = $esxiHandle
    }
    New-CertificatePair @params

    Write-SeparatorLine

    Write-Output -InputObject $($configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($deployment.Hostname)"}) | Out-String

    # Join the vcsa to the windows domain.
    $params = @{
        deployment = $deployment
        adInfo = $configData.ADInfo | Where-Object {$configData.ADInfo.vCenter -match "all|$($deployment.Hostname)"}
        viHandle = $esxiHandle
    }
    Join-ADDomain @params

    # if the vcsa is not a stand alone PSC, configure the vCenter.
    if ($deployment.DeployType -ne "infrastructure") {

        Write-Output -InputObject "== vCenter $($deployment.vmName) configuration ==" | Out-String

        Write-SeparatorLine

        $datacenters = $configData.Sites | Where-Object {$_.vcenter.Split(",") -match "all|$($deployment.Hostname)"}
        $ssoSecPasswd = ConvertTo-SecureString -String $($deployment.SSOAdminPass) -AsPlainText -Force
        $ssoCreds = New-Object -TypeName System.Management.Automation.PSCredential ($("Administrator@" + $deployment.SSODomainName), $ssoSecPasswd)

        # Connect to the vCenter
        $params = @{
            server = $deployment.Hostname
            credential = $ssoCreds
        }
        $vcHandle = Connect-VIServer @params

        # Create Datacenter
        if ($datacenters) {
            $datacenters.Datacenter.ToUpper() | ForEach-Object {New-Datacenter -Location Datacenters -Name $_}
        }

        # Create Folders, Roles, and Permissions.
        $folders = $configData.Folders | Where-Object {$_.vcenter.Split(",") -match "all|$($deployment.Hostname)"}
        if ($folders) {
            Write-Output -InputObject "Folders:" $folders
            $params = @{
                folder = $folders
                viHandle = $viHandle
            }
            New-Folders @params
        }

        # if this is the first vCenter, create custom Roles.
        $existingRoles = Get-VIRole -Server $vcHandle
        $roles = $configData.Roles | Where-Object {$_.vcenter.Split(",") -match "all|$($deployment.Hostname)"} | Where-Object {$existingRoles -notcontains $_.Name}
           if ($roles) {
            Write-Output -InputObject "Roles:" $roles
            $params = @{
                roles = $roles
                viHandle = $vcHandle
            }
            Add-Roles @params
        }

        # Create OS Customizations for the vCenter.
        $configData.OSCustomizations | Where-Object {$_.vCenter -eq $deployment.Hostname} | ForEach-Object {ConvertTo-OSString -InputObject $_}

        # Create Clusters
        ForEach ($datacenter in $datacenters) {
            # Define IP Octets
            $octet1 = $datacenter.octet1
            $octet2 = $datacenter.octet2
            $octet3 = $datacenter.octet3

            # Create the cluster if it is defined for all vCenters or the current vCenter and the current Datacenter.
               ($configData.Clusters | Where-Object {($_.vCenter.Split(",") -match "all|$($deployment.Hostname)")`
                   -and ($_.Datacenter.Split(",") -match "all|$($datacenter.Datacenter)")}).Clustername |`
                ForEach-Object {if ($_) {New-Cluster -Location (Get-Datacenter -Server $vcHandle -Name $datacenter.Datacenter) -Name $_}}

            # Create New vDSwitch
            # Select vdswitches if definded for all vCenters or the current vCentere and the current Datacenter.
            $vdSwitches = $configData.VDSwitches | Where-Object {($_.vCenter.Split(",") -match "all|$($deployment.Hostname)") -and ($_.Datacenter.Split(",") -match "all|$($datacenter.Datacenter)")}

            ForEach ($vdSwitch in $vdSwitches) {
                $switchDatacenter = Get-Inventory -Name $datacenter.Datacenter

                if ($vdSwitch.SwitchNumber.ToString().indexof(".") -eq -1) {
                    $switchNumber = $vdSwitch.SwitchNumber.ToString() + ".0"
                } else {
                    $switchNumber = $vdSwitch.SwitchNumber.ToString()
                }

                $switchName = $switchNumber + " " + $vdSwitch.vDSwitchName -replace "XXX", $datacenter.Datacenter

                if ($vdSwitch.JumboFrames) {
                    $mtu = 9000
                } else {
                    $mtu = 1500
                }

                # Create new vdswitch.
                $params = @{
                    server = $vcHandle
                    name = $switchName
                    location = $switchDatacenter
                    mtu = $mtu
                    numUplinkPorts = 2
                    version = $vdSwitch.Version
                }
                New-VDSwitch @params

                # Enable NIOC
                $params = @{
                    server = $vcHandle
                    name = $switchName
                }
                (Get-vDSwitch @params | Get-View).EnableNetworkResourceManagement($true)

                $vlanAdd = $configData.VLANS | Where-Object {$_.Number.StartsWith($switchName.Split(" ")[0])}
                $vlanAdd = $vlanAdd | Where-Object {$_.Datacenter.Split(",") -match "all|$($datacenter.Datacenter)"}
                $vlanAdd = $vlanAdd | Where-Object {$_.vCenter.Split(",") -match "all|$($deployment.Hostname)"}

                # Create Portgroups
                ForEach ($vlan in $vlanAdd) {

                    $portGroup = $vlan.Number.padright(8," ") +`
                                 $vlan.Vlan.padright(8," ") + "- " +`
                                 $vlan.Network.padright(19," ") + "- " +`
                                 $vlan.VlanName

                    $portGroup = $portGroup -replace "octet1", $octet1
                    $portGroup = $portGroup -replace "octet2", $octet2
                    $portGroup = $portGroup -replace "octet2", $octet3

                    if ($portGroup.Split("-")[0] -like "*trunk*") {
                        $params = @{
                            server = $vcHandle
                            vdSwitch = $switchName
                            name = $portGroup
                            notes = $portGroup.Split("-")[0]
                            vlanTrunkRange = $vlan.network
                        }
                        New-VDPortgroup @params
                    } else {
                        $params = @{
                            server = $vcHandle
                            vdSwitch = $switchName
                            name = $portGroup
                            notes = $portGroup.Split("-")[1]
                        }
                        New-VDPortgroup @params
                    }
                    # Set Portgroup Team policies
                    if ($portGroup -like "*vmotion-1*") {
                        Get-vdportgroup -Server $vcHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $portGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $vcHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink1" -StandbyUplinkPort "dvUplink2"
                    }
                    if ($portGroup -like "*vmotion-2*") {
                        Get-vdportgroup -Server $vcHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $portGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $vcHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -EnableFailback $true -ActiveUplinkPort "dvUplink2" -StandbyUplinkPort "dvUplink1"
                    }
                    if ($portGroup -notlike "*vmotion*") {
                        Get-vdportgroup -Server $vcHandle | `
                            Where-Object {$_.Name.Split('%')[0] -like $portGroup.Split('/')[0]} | `
                            Get-VDUplinkTeamingPolicy -Server $vcHandle | `
                            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -EnableFailback $false
                    } else {
                        #Set Traffic Shaping on vmotion portgroups for egress traffic
                        Get-VDPortgroup -Server $vcHandle -VDSwitch $switchName | `
                            Where-Object {$_.Name.Split('%')[0] -like $portGroup.Split('/')[0]} | `
                            Get-VDTrafficShapingPolicy -Server $vcHandle -Direction Out | `
                            Set-VDTrafficShapingPolicy -Enabled:$true -AverageBandwidth 8589934592 -PeakBandwidth 8589934592 -BurstSize 1
                    }
                }
            }
        }

        # Add Licenses to vCenter.
        if ($configData.Licenses | Where-Object {$_.vCenter -eq $deployment.Hostname}) {
            Add-Licensing -Licenses $($configData.Licenses | Where-Object {$_.vCenter -eq $deployment.Hostname}) -VIHandle $vcHandle
        }

        # Select permissions for all vCenters or the current vCenter.
        # Create the permissions.
        $params = @{
            vPermissions = $configData.Permissions | Where-Object {$_.vCenter.Split(",") -match "all|$($deployment.Hostname)"}
            viHandle = $vcHandle
        }
        New-Permissions @params

        $instanceCertPath = $certPath + "\" + $deployment.Hostname

        # Configure Additional Services (Network Dump, Autodeploy, TFTP)
        ForEach ($serv in $configData.Services) {
            Write-Output -InputObject $serv | Out-String
            if ($serv.vCenter.Split(",") -match "all|$($deployment.Hostname)") {
                switch ($serv.Service) {
                    "AuthProxy" {
                        $params = {
                            deployment = $deployment
                            viHandle = $esxiHandle
                            adDomain = $configData.ADInfo | Where-Object {$_.vCenter -match "all|$($deployment.Hostname)"}
                        }
                        New-AuthProxyService @params
                        break
                    }
                    "AutoDeploy" {
                        $vcHandle | Get-AdvancedSetting -Name vpxd.certmgmt.certs.minutesBefore | Set-AdvancedSetting -Value 1 -Confirm:$false
                        $params = @{
                            Deployment = $deployment
                            VIHandle = $esxiHandle
                        }
                        New-AutoDeployService @params
                        if ($configData.AutoDepRules | Where-Object {$_.vCenter -eq $deployment.Hostname}) {
                            $params = @{
                                rules = $configData.AutoDepRules | Where-Object {$_.vCenter -eq $deployment.Hostname}
                                path = $folderPath
                                viHandle = $vcHandle
                            }
                            New-AutoDeployRule @params
                        }
                        break
                    }
                    "Netdumpster" {
                        $params = @{
                            hostname = $deployment.Hostname
                            credential = $vcsaCredential
                            viHandle = $esxiHandle
                        }
                        New-NetDumpsterService @params
                        break
                    }
                    "TFTP" {
                        $params = @{
                            hostname = $deployment.Hostname
                            credential = $vcsaCredential
                            viHandle = $esxiHandle
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
        $plugins = $configData.Plugins | Where-Object {$_.config -and $_.vCenter.Split(",") -match "all|$($deployment.Hostname)"}

        Write-SeparatorLine
        Write-Output -InputObject $plugins | Out-String
        Write-SeparatorLine

        for ($i=0;$i -lt $plugins.Count;$i++) {
            if ($plugins[$i].SourceDir) {
                if ($commandList) {
                    $params = @{
                        script = $commandList
                        hostname = $deployment.Hostname
                        credential = $vcsaCredential
                        viHandle = $esxiHandle
                    }
                    Invoke-ExecuteScript @params
                    $commandList = $null
                    $commandList = @()
                }
                $fileLocations = $null
                $fileLocations = @()
                $fileLocations += "$($folderPath)\$($plugins[$i].SourceDir)\$($plugins[$i].SourceFiles)"
                $fileLocations += $plugins[$i].DestDir
                Write-Output -InputObject $fileLocations | Out-String
                $params = @{
                    path = $fileLocations
                    hostname = $deployment.Hostname
                    credential = $vcsaCredential
                    VIHandle = $viHandle
                    upload = $true
                }
                Copy-FileToServer @params
            }
            if ($plugins[$i].Command) {
                $commandList += $plugins[$i].Command
            }
        }

        if ($commandList) {
            $params = @{
                script = $commandList
                hostname = $deployment.Hostname
                credential = $vcsaCredential
                viHandle = $esxiHandle
            }
            Invoke-ExecuteScript @params
        }

        Write-SeparatorLine

        Write-Output -InputObject "Adding Build Cluster Alarm" | Out-String

        $dc = $deployment.Hostname.Split(".")[1]

        $alarmMgr = Get-View AlarmManager
        $entity = Get-Datacenter -Name $dc -Server $vcHandle | Get-Cluster -Name "build" | Get-View

        # AlarmSpec
        $alarm = New-Object -TypeName VMware.Vim.AlarmSpec
        $alarm.Name = "1. Configure New Esxi Host"
        $alarm.Description = "Configure a New Esxi Host added to the vCenter"
        $alarm.Enabled = $TRUE

        $alarm.action = New-Object -TypeName VMware.Vim.GroupAlarmAction

        $trigger = New-Object -TypeName VMware.Vim.AlarmTriggeringAction
        $trigger.action = New-Object VMware.Vim.RunScriptAction
        $trigger.action.Script = "/root/esxconf.sh {targetName}"

        # Transition a - yellow --> red
        $transA = New-Object -TypeName VMware.Vim.AlarmTriggeringActionTransitionSpec
        $transA.StartState = "yellow"
        $transA.FinalState = "red"

        $trigger.TransitionSpecs = $transA

        $alarm.action = $trigger

        $expression = New-Object -TypeName VMware.Vim.EventAlarmExpression
        $expression.EventType = "EventEx"
        $expression.eventTypeId = "vim.event.HostConnectedEvent"
        $expression.objectType = "HostSystem"
        $expression.status = "red"

        $alarm.expression = New-Object -TypeName VMware.Vim.OrAlarmExpression
        $alarm.expression.expression = $expression

        $alarm.setting = New-Object -TypeName VMware.Vim.AlarmSetting
        $alarm.setting.reportingFrequency = 0
        $alarm.setting.toleranceRange = 0

        # Create alarm.
        $alarmMgr.CreateAlarm($entity.MoRef, $alarm)

        # Disconnect from the vCenter.
        $params = @{
            server = $vcHandle
            confirm = $false
        }
        Disconnect-VIServer @params

        Write-SeparatorLine
    }

    # Run the vami_set_Hostname to set the correct FQDN in the /etc/hosts file on a vCenter with External PSC only.
    if ($deployment.DeployType -like "*management*") {
        $commandList = $null
        $commandList = @()
        $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandList += "export VMWARE_LOG_DIR=/var/log"
        $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandList += "export VMWARE_DATA_DIR=/storage"
        $commandList += "/opt/vmware/share/vami/vami_set_hostname $($deployment.Hostname)"
        $params = @{
            script = $commandList
            hostname = $deployment.Hostname
            credential = $vcsaCredential
            viHandle = $esxiHandle
        }
        Invoke-ExecuteScript @params
    }

    # Disconnect from the vcsa deployed esxi server.
    $params = @{
        server = $esxiHandle
        confirm = $false
    }
    Disconnect-VIServer @params

    Write-SeparatorLine

    Write-Host -Object "=============== End of Configuration for $($deployment.vmName) ===============" | Out-String

    Stop-Transcript
}

Write-SeparatorLine

Write-Output -InputObject "<=============== Deployment Complete ===============>" | Out-String

Set-Location -Path $folderPath

# Get Certificate folders that do not have a Date/Time in their name.
$certFolders = (Get-Childitem -Path $($folderPath + "\Certs") -Directory).FullName | Where-Object {$_ -notmatch '\d\d-\d\d-\d\d\d\d'}

# Rename the folders to add Date/Time to the name.
$certFolders | ForEach-Object {
    Rename-Item -Path $_ -NewName $($_ + "-" + $(Get-Date -Format "MM-dd-yyyy_HH-mm"))
}

# Scrub logfiles
$logFiles = (Get-ChildItem -Path $logPath).FullName

if ($configData.Summary.TranscriptScrub) {
    ForEach ($log in $logFiles) {
        $transcript = Get-Content -Path $log
        ForEach ($Pass in $scrub) {
            $transcript = $transcript.replace($Pass,'<-- Password Redacted -->')
        }
        $transcript | Set-Content -Path $log -Force -Confirm:$false
    }
}