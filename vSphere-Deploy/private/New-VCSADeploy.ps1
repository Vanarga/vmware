function New-VCSADeploy {
    <#
    .SYNOPSIS
        Deploy a VCSA.

    .DESCRIPTION

    .PARAMETER ParameterList

    .PARAMETER OvfToolPath

    .PARAMETER LogPath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-VCSADeploy -ParameterList < > -OvfToolPath < > -LogPath < >

        PS C:\> New-VCSADeploy

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-VCSADeploy
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ParameterList,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $OvfToolPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $LogPath
    )

    $pscs = @("tiny","small","medium","large","infrastructure")

    $argumentList = @()
    $ovfTool = $OvfToolPath + "\ovftool.exe"

    # Get Esxi Host Certificate Thumbrpint.
    $url = "https://" + $ParameterList.esxiHost
    $webRequest = [Net.WebRequest]::Create($Url)
    Try {
        $webRequest.GetResponse()
    }
    Catch {}
    $esxiCert = $webRequest.ServicePoint.Certificate
    $esxiThumbPrint = $esxiCert.GetCertHashString() -replace '(..(?!$))','$1:'

    if ($Parameterlist.Action -ne "--version") {
        $argumentList += "--X:logFile=$LogPath\ofvtool_" + $ParameterList.vmName + "-" + $(Get-Date -format "MM-dd-yyyy_HH-mm") + ".log"
        $argumentList += "--X:logLevel=verbose"
        $argumentList += "--acceptAllEulas"
        $argumentList += "--skipManifestCheck"
        $argumentList += "--targetSSLThumbprint=$esxiThumbPrint"
        $argumentList += "--X:injectOvfEnv"
        $argumentList += "--allowExtraConfig"
        $argumentList += "--X:enableHiddenProperties"
        $argumentList += "--X:waitForIp"
        $argumentList += "--sourceType=OVA"
        $argumentList += "--powerOn"
        $argumentList += "--net:Network 1=" + $ParameterList.EsxiNet
        $argumentList += "--datastore=" + $ParameterList.esxiDatastore
        $argumentList += "--diskMode=" + $ParameterList.DiskMode
        $argumentList += "--name=" + $ParameterList.vmName
        $argumentList += "--deploymentOption=" + $ParameterList.DeployType
        if ($Parameterlist.DeployType -like "*management*") {
            $argumentList += "--prop:guestinfo.cis.system.vm0.hostname=" + $ParameterList.Parent
        }
        $argumentList += "--prop:guestinfo.cis.vmdir.domain-name=" + $ParameterList.SSODomainName
        $argumentList += "--prop:guestinfo.cis.vmdir.site-name=" + $ParameterList.SSOSiteName
        $argumentList += "--prop:guestinfo.cis.vmdir.password=" + $ParameterList.SSOAdminPass
        if ($Parameterlist.Action -eq "first" -and $pscs -contains $ParameterList.DeployType) {
            $argumentList += "--prop:guestinfo.cis.vmdir.first-instance=True"
        } else {
              $argumentList += "--prop:guestinfo.cis.vmdir.first-instance=False"
              $argumentList += "--prop:guestinfo.cis.vmdir.replication-partner-Hostname=" + $ParameterList.Parent
        }
        $argumentList += "--prop:guestinfo.cis.appliance.net.addr.family=" + $ParameterList.NetFamily
        $argumentList += "--prop:guestinfo.cis.appliance.net.addr=" + $ParameterList.IP
        $argumentList += "--prop:guestinfo.cis.appliance.net.pnid=" + $ParameterList.Hostname
        $argumentList += "--prop:guestinfo.cis.appliance.net.prefix=" + $ParameterList.NetPrefix
        $argumentList += "--prop:guestinfo.cis.appliance.net.mode=" + $ParameterList.NetMode
        $argumentList += "--prop:guestinfo.cis.appliance.net.dns.servers=" + $ParameterList.DNS
        $argumentList += "--prop:guestinfo.cis.appliance.net.gateway=" + $ParameterList.Gateway
        $argumentList += "--prop:guestinfo.cis.appliance.root.passwd=" + $ParameterList.VCSARootPass
        $argumentList += "--prop:guestinfo.cis.appliance.ssh.enabled=" + $ParameterList.EnableSSH
        $argumentList += "--prop:guestinfo.cis.appliance.ntp.servers=" + $ParameterList.NTP
        $argumentList += "--prop:guestinfo.cis.deployment.autoconfig=True"
        $argumentList += "--prop:guestinfo.cis.clientlocale=en"
        $argumentList += "--prop:guestinfo.cis.ceip_enabled=False"
        $argumentList += $ParameterList.OVA
        $argumentList += "vi://" + $ParameterList.esxiRootUser + "`:" + $ParameterList.esxiRootPass + "@" + $ParameterList.esxiHost
    }

    Write-Output -InputObject $argumentList | Out-String

    & $ovfTool $argumentList

    return
}