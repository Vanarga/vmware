function Join-AdDomain {
    <#
    .SYNOPSIS
        Join the VCSA to the Windows AD Domain.

    .DESCRIPTION
        Join the VCSA to the Windows AD Domain.

    .PARAMETER Deployment
        The mandatory parameter Deployment contains all the settings for a specific vSphere node deployement.

    .PARAMETER AdInfo
        The manadatory string array AdInfo contains all the information about the Active Directory domain.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Join-AdDomain -Deployment <String[]>
                      -AdInfo <String[]>
                      -ViHandle <Vi Session>

        PS C:\> Join-ADDomain

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Join-AdDomain
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$AdInfo,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    $pscDeployments = @("tiny","small","medium","large","infrastructure")
    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    Write-Output -InputObject "== Joining $($Deployment.vmName) to the windows domain ==" | Out-String

    Write-SeparatorLine

    $commandList = $null
    $commandList = @()
    $commandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
    $commandList += 'export VMWARE_LOG_DIR=/var/log'
    $commandList += 'export VMWARE_DATA_DIR=/storage'
    $commandList += 'export VMWARE_CFG_DIR=/etc/vmware'
    $commandList += '/usr/bin/service-control --start --all --ignore'
    $commandList += "/opt/likewise/bin/domainjoin-cli join " + $AdInfo.ADDomain + " " + $AdInfo.ADJoinUser + " `'" + $AdInfo.ADJoinPass + "`'"
    $commandList += "/opt/likewise/bin/domainjoin-cli query"

    # Excute the commands in $commandList on the vcsa.
    $params = @{
        Script = $commandList
        Hostname = $Deployment.vmName
        Credential = $credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params
    $params = @{
        VM = $Deployment.vmName
        Server = $ViHandle
        Confirm = $false
    }
    Restart-VMGuest @params

    # Write separator line to transcript.
    Write-SeparatorLine

    # Wait 60 seconds before checking availability to make sure the vcsa is booting up and not in the process of shutting down.
    Start-Sleep -Seconds 60

    # Wait until the vcsa is Get-URLStatus.
    Get-URLStatus -URL $("https://" + $Deployment.Hostname)

    # Write separator line to transcript.
    Write-SeparatorLine

    # Check domain status.
    $commandList = $null
    $commandList = @()
    $commandList += 'export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages'
    $commandList += 'export VMWARE_LOG_DIR=/var/log'
    $commandList += 'export VMWARE_DATA_DIR=/storage'
    $commandList += 'export VMWARE_CFG_DIR=/etc/vmware'
    $commandList += '/usr/bin/service-control --start --all --ignore'
    $commandList += "/opt/likewise/bin/domainjoin-cli query"

    # Excute the commands in $commandList on the vcsa.
    $params = @{
        Script = $commandList
        Hostname = $Deployment.vmName
        Credential = $credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @parmas

    # if the vcsa is the first PSC in the vsphere domain, set the default identity source to the windows domain,
    # add the windows AD group to the admin groups of the PSC.
    $commandList = $null
    $commandList = "/opt/likewise/bin/ldapsearch -h " + $Deployment.Hostname + " -w `'" + $Deployment.VCSARootPass + "`' -x -D `"cn=Administrator,cn=Users,dc=lab-hcmny,dc=com`" -b `"cn=lab-hcmny.com,cn=Tenants,cn=IdentityManager,cn=services,dc=lab-hcmny,dc=com`" | grep vmwSTSDefaultIdentityProvider"
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
    }
    $DefaultIdentitySource = $(Invoke-ExecuteScript @params).Scriptoutput

    $versionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'

    $params = @{
        Script = "echo `'" + $Deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
    }
    Write-Output -InputObject $params.Script | Out-String
    $viVersion = $(Invoke-ExecuteScript @params).Scriptoutput.Split("") | Select-String -pattern $versionRegex

    Write-Output -InputObject $viVersion

    if ($viVersion -match "6.7." -and $Deployment.DeployType -ne "infrastructure" -and $DefaultIdentitySource -ne $AdInfo.ADDomain) {
        # Write separator line to transcript.
        Write-SeparatorLine

        New-IdentitySourcevCenter67 -Deployment $Deployment -ADInfo $AdInfo

        Write-SeparatorLine

        Add-SsoAdminGroups -Deployment $Deployment -ADInfo $AdInfo -ViHandle $ViHandle
    } elseif ($viVersion -match "6.5." -and $pscDeployments -contains $Deployment.DeployType) {
        Write-SeparatorLine

        New-IdentitySourcevCenter65 -Deployment $Deployment

        Write-SeparatorLine

        Add-SsoAdminGroups -Deployment $Deployment -ADInfo $AdInfo -ViHandle $ViHandle
    }

    Write-SeparatorLine
}