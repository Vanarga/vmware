function New-TFTPService {
    <#
    .SYNOPSIS
        Configure TFTP, set firewall exemption, set service to auto start, start service.

    .DESCRIPTION

    .PARAMETER Hostname

    .PARAMETER Username

    .PARAMETER Password

    .PARAMETER ViHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-TFTPService -Hostname < > -Username < > -Password < > -ViHandle < >

        PS C:\> New-TFTPService

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-TFTPService
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Hostname,
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
