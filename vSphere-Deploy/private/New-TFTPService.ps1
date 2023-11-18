function New-TftpService {
    <#
    .SYNOPSIS
        Configure TFTP, set firewall exemption, set service to auto start, start service.

    .DESCRIPTION
        Configure TFTP, set firewall exemption, set service to auto start, start service.

    .PARAMETER Hostname
        The mandatory string parameter Hostname is the name of the host on which the TFTP service is to be configured.

    .PARAMETER Credential
        The mandatory secure string parameter Credential is the credentials needed to connect to the host.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-TftpService -Hostname <String>
                        -Credential <Secure String>
                        -ViHandle <VI Session>

        PS C:\> New-TftpService

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-TftpService
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$Hostname,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [SecureString]$Credential,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    $commandList = $null
    $commandList = @()

    # Set Permanent Firewall Exception
    $commandList += 'echo -e "{" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "      \"firewall\": {" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "      \"enable\": true," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "      \"rules\": [" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          {" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"protocol\": \"tcp\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          }," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "      {" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"direction\": \"inbound\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"protocol\": \"udp\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"porttype\": \"dst\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"port\": \"69\"," >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "          \"portoffset\": 0" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "      }" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "    ]" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "  }" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += 'echo -e "}" >> /etc/vmware/appliance/firewall/tftp'
    $commandList += "echo `"#!/bin/bash`" > /tmp/tftpcmd"
    $commandList += "echo -n `"sed -i `" >> /tmp/tftpcmd"
    $commandList += "echo -n `'`"s/`' >> /tmp/tftpcmd"
    $commandList += "echo -n \`'/ >> /tmp/tftpcmd"
    $commandList += "echo -n `'\`' >> /tmp/tftpcmd"
    $commandList += "echo -n `'`"/g`' >> /tmp/tftpcmd"
    $commandList += "echo -n `'`"`' >> /tmp/tftpcmd"
    $commandList += "echo -n `" /etc/vmware/appliance/firewall/tftp`" >> /tmp/tftpcmd"
    $commandList += "chmod a+x /tmp/tftpcmd"
    $commandList += "/tmp/tftpcmd"
    $commandList += "rm /tmp/tftpcmd"

    $commandList += "more /etc/vmware/appliance/firewall/tftp"
    # Enable TFTP service.
    $commandList += "/sbin/chkconfig atftpd on"
    # Start TFTP service.
    $commandList += "/etc/init.d/atftpd start"
    $commandList += "/usr/lib/applmgmt/networking/bin/firewall-reload"
    # Set Firewall Exception until reboot.
    $commandList += "iptables -A port_filter -p udp -m udp --dport 69 -j ACCEPT"

    # Service update
    $params = @{
        Script = $commandList
        Hostname = $Hostname
        Credential = $Credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params
}
