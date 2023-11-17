function Copy-CertificateToHost {
    <#
    .SYNOPSIS
        Copy the certificate to the host.

    .DESCRIPTION

    .PARAMETER rootCertPath

    .PARAMETER certPath

    .PARAMETER deployment

    .PARAMETER viHandle

    .PARAMETER deploymentParent

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Copy-CertificateToHost -rootCertPath < >
                               -certPath < >
                               -deployment < >
                               -viHandle < >
                               -deploymentParent < >

        PS C:\> Copy-CertificateToHost

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Copy-CertificateToHost
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $rootCertPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $viHandle,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $deploymentParent
    )

    # http://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.security.doc/GUID-BD70615E-BCAA-4906-8E13-67D0DBF715E4.html
    # Copy SSL certificates to a VCSA and replace the existing ones.

    $pscDeployments = @("tiny","small","medium","large","infrastructure")

    $certPath = "$certPath\" + $deployment.Hostname
    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $deployment.VCSARootPass -AsPlainText -Force))
    $sslPath = "/root/ssl"
    $solutionPath = "/root/solutioncerts"
    $params = @{
        script = "mkdir $sslPath;mkdir $solutionPath"
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Invoke-ExecuteScript @params

    $versionRegex = '\b\d{1}\.\d{1}\.\d{1,3}\.\d{1,5}\b'

    $params = @{
        script = "echo `'" + $deployment.VCSARootPass + "`' | appliancesh 'com.vmware.appliance.version1.system.version.get'"
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Write-Output $params.Script | Out-String
    $viVersion = $(Invoke-ExecuteScript @params).Scriptoutput.Split("") | Select-String -pattern $versionRegex

    Write-Output $viVersion

    $filePath = $null
    $filePath = @()
    $filePath += "$certPath\machine\new_machine.crt"
    $filePath += "$sslPath/new_machine.crt"
    $filePath += "$certPath\machine\new_machine.cer"
    $filePath += "$sslPath/new_machine.cer"
    $filePath += "$certPath\machine\ssl_key.priv"
    $filePath += "$sslPath/ssl_key.priv"
    if ($pscDeployments -contains $deployment.DeployType) {
        if (Test-Path -Path "$rootCertPath\root64.cer") {
            $filePath += "$rootCertPath\root64.cer"
            $filePath += "$sslPath/root64.cer"
        }
        if (Test-Path -Path "$rootCertPath\interm64.cer") {
            $filePath += "$rootCertPath\interm64.cer"
            $filePath += "$sslPath/interm64.cer"
        }
        if (Test-Path -Path "$rootCertPath\interm264.cer") {
            $filePath += "$rootCertPath\interm264.cer"
            $filePath += "$sslPath/interm264.cer"}
        }
    if (Test-Path -Path "$rootCertPath\interm64.cer") {
        $filePath += "$rootCertPath\chain.cer"
        $filePath += "$sslPath/chain.cer"
    }
    $filePath += "$certPath\solution\machine.cer"
    $filePath += "$solutionPath/machine.cer"
    $filePath += "$certPath\solution\machine.priv"
    $filePath += "$solutionPath/machine.priv"
    $filePath += "$certPath\solution\vsphere-webclient.cer"
    $filePath += "$solutionPath/vsphere-webclient.cer"
    $filePath += "$certPath\solution\vsphere-webclient.priv"
    $filePath += "$solutionPath/vsphere-webclient.priv"
    if ($deployment.DeployType -ne "Infrastructure") {
        $filePath += "$certPath\solution\vpxd.cer"
        $filePath += "$solutionPath/vpxd.cer"
        $filePath += "$certPath\solution\vpxd.priv"
        $filePath += "$solutionPath/vpxd.priv"
        $filePath += "$certPath\solution\vpxd-extension.cer"
        $filePath += "$solutionPath/vpxd-extension.cer"
        $filePath += "$certPath\solution\vpxd-extension.priv"
        $filePath += "$solutionPath/vpxd-extension.priv"
    }
    $params = @{
        Path = $filepath
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
        upload = $true
    }
    Copy-FileToServer @params

    $commandList = $null
    $commandList = @()

    # Set path for python.
    $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
    $commandList += "export VMWARE_LOG_DIR=/var/log"
    $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
    $commandList += "export VMWARE_DATA_DIR=/storage"
    # Stop all services.
    $commandList += "service-control --stop --all"
    # Start vmafdd,vmdird, and vmca services.
    $commandList += "service-control --start vmafdd"
    if ($pscDeployments -contains $deployment.DeployType) {
        $commandList += "service-control --start vmdird"
        $commandList += "service-control --start vmca"
    }

    # Replace the root cert.
    if ($pscDeployments -contains $deployment.DeployType) {
        if (Test-Path -Path "$rootCertPath\root64.cer") {
            $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $sslPath/root64.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
        }
        if (Test-Path -Path "$rootCertPath\interm64.cer") {
            $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $sslPath/interm64.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
        }
        if (Test-Path -Path "$rootCertPath\interm264.cer") {
            $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert publish --cert $sslPath/interm264.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
        }
    }

    # Add certIficate chain to TRUSTED_ROOTS of the PSC for ESXi Cert Replacement.
    # if ($pscDeployments -contains $deployment.DeployType -and (Test-Path -Path "$rootCertPath\interm64.cer")) {
    <#if ($deployment.DeployType -eq "Infrastructure" -and (Test-Path -Path "$rootCertPath\interm64.cer")) {
        $commandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry create --store TRUSTED_ROOTS --alias chain.cer --cert $sslPath/chain.cer"
    }#>

    # Retrive the Old Machine Cert and save its thumbprint to a file.
    $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store MACHINE_SSL_CERT --alias __MACHINE_CERT --output $sslPath/old_machine.crt"
    $commandList += "openssl x509 -in $sslPath/old_machine.crt -noout -sha1 -fingerprint > $sslPath/thumbprint.txt"

    # Replace the Machine Cert.
    $commandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store MACHINE_SSL_CERT --alias __MACHINE_CERT"
    $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store MACHINE_SSL_CERT --alias __MACHINE_CERT --cert $sslPath/new_machine.cer --key $sslPath/ssl_key.priv"
    $params = @{
        script = $commandList
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Invoke-ExecuteScript @params

    $commandList = $null
    $commandList = @()
    $commandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vsphere-webclient --alias vsphere-webclient"
    $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vsphere-webclient --alias vsphere-webclient --cert $solutionPath/vsphere-webclient.cer --key $solutionPath/vsphere-webclient.priv"
    # Skip If server is an External PSC. - vpxd and vpxd-extension do not need to be replaced on an external PSC.
    if ($deployment.DeployType -ne "Infrastructure") {
        $commandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd --alias vpxd"
        $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd --alias vpxd --cert $solutionPath/vpxd.cer --key $solutionPath/vpxd.priv"
        $commandList += "echo Y | /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store vpxd-extension --alias vpxd-extension"
        $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry create --store vpxd-extension --alias vpxd-extension --cert $solutionPath/vpxd-extension.cer --key $solutionPath/vpxd-extension.priv"
    }
    $params = @{
        script = $commandList
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Invoke-ExecuteScript @params

    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/vmware-vmafd/bin/vmafd-cli get-machine-id --server-name localhost"
    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli service list --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"

    $params = @{
        scriptText = $commandList[0]
        vm = $deployment.Hostname
        guestUser = "root"
        guestPassword = $deployment.VCSARootPass
        server = $viHandle
    }
    $uniqueID = Invoke-VMScript @params
    $params = @{
        scriptText = $commandList[1]
        vm = $deployment.Hostname
        guestUser = "root"
        guestPassword = $deployment.VCSARootPass
        server = $viHandle
    }
    $certList = Invoke-VMScript @params

    Write-SeparatorLine

    Write-Output "Unique ID: " + $uniqueID | Out-String
    Write-Output "Certificate List: " + $certList | Out-String

    Write-SeparatorLine

    # Retrieve unique key list relevant to the server.
    $solutionUsers = ($certlist.ScriptOutput.Split(".").Split("`n") | ForEach-Object {if ($_[0] -eq " ") {$_}} | Where-Object {$_.ToString() -like "*$($uniqueID.ScriptOutput.Split("`n")[0])*"}).Trim(" ")

    Write-SeparatorLine

    Write-Output "Solution Users: " + $solutionUsers | Out-String

    Write-SeparatorLine

    $commandList = $null
    $commandList = @()

    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $solutionUsers[1] + " --cert $solutionPath/vsphere-webclient.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
    if ($deployment.DeployType -ne "Infrastructure") {
        $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $solutionUsers[2] + " --cert $solutionPath/vpxd.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
        $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli service update --name " + $solutionUsers[3] + " --cert $solutionPath/vpxd-extension.cer --login `'administrator@" + $deployment.SSODomainName + "`' --password `'" + $deployment.SSOAdminPass + "`'"
    }

    # Set path for python.
    $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
    $commandList += "export VMWARE_LOG_DIR=/var/log"
    $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
    $commandList += "export VMWARE_DATA_DIR=/storage"
    # Start all services.
    $commandList += "service-control --start --all --ignore"

    # Service update
    $params = @{
        script = $commandList
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Invoke-ExecuteScript @params

    Start-Sleep -Seconds 10

    if ($deployment.DeployType -ne "Infrastructure") {
        $commandList = $null
        $commandList = @()
        # Set path for python.
        $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandList += "export VMWARE_LOG_DIR=/var/log"
        $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandList += "export VMWARE_DATA_DIR=/storage"
        # Replace EAM Solution User Cert.
        $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getcert --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.crt"
        $commandList += "/usr/lib/vmware-vmafd/bin/vecs-cli entry getkey --store vpxd-extension --alias vpxd-extension --output /root/solutioncerts/vpxd-extension.key"
        $commandList += "/usr/bin/python /usr/lib/vmware-vpx/scripts/updateExtensionCertInVC.py -e com.vmware.vim.eam -c /root/solutioncerts/vpxd-extension.crt -k /root/solutioncerts/vpxd-extension.key -s " + $deployment.Hostname + " -u administrator@" + $deployment.SSODomainName + " -p `'" + $deployment.SSOAdminPass + "`'"
        $commandList += '/usr/bin/service-control --stop vmware-eam'
        $commandList += '/usr/bin/service-control --start vmware-eam'

        # Service update
        $params = @{
            script = $commandList
            hostname = $deployment.Hostname
            credential = $credential
            viHandle = $viHandle
        }
        Invoke-ExecuteScript @params
    }

    # Update VAMI Certs on External PSC.
    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/applmgmt/support/scripts/postinstallscripts/setup-webserver.sh"

    # Service update
    $params = @{
        script = $commandList
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    Invoke-ExecuteScript @params

    # Refresh Update Manager CertIficates.
    if ($viVersion -match "6.5." -and $deployment.DeployType -ne "Infrastructure") {
        $commandList = $null
        $commandList = @()
        # Set path for python.
        $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandList += "export VMWARE_LOG_DIR=/var/log"
        $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandList += "export VMWARE_DATA_DIR=/storage"
        $commandList += "export VMWARE_RUNTIME_DATA_DIR=/var"
        $commandList += "/usr/lib/vmware-updatemgr/bin/updatemgr-util refresh-certs"
        $commandList += "/usr/lib/vmware-updatemgr/bin/updatemgr-util register-vc"

        # Service update
        $params = @{
            script = $commandList
            hostname = $deployment.Hostname
            credential = $credential
            viHandle = $viHandle
        }
        Invoke-ExecuteScript @params
    }

    # Refresh Update Manager CertIficates.
    if ($viVersion -match "6.7." -and $deployment.DeployType -ne "Infrastructure") {

        # Service update
        $params = @{
            script = "echo `'$deployment.VCSARootPass`' | appliancesh com.vmware.updatemgr-util register-vc"
            hostname = $deployment.Hostname
            credential = $credential
            viHandle = $viHandle
        }
        Invoke-ExecuteScript @params
    }

    # Assign the original machine certIficate thumbprint to $thumbprint and remove the carriage return.
    # Change the shell to Bash to enable scp and retrieve the original machine certIficate thumbprint.
    $commandList = $null
    $commandList = @()
    $commandList += "chsh -s /bin/bash"
    $commandList += "cat /root/ssl/thumbprint.txt"
    $params = @{
        script = $commandList
        hostname = $deployment.Hostname
        credential = $credential
        viHandle = $viHandle
    }
    $thumbprint = $(Invoke-ExecuteScript @params).Scriptoutput.Split("=",2)[1]
    $thumbprint = $thumbprint -replace "`t|`n|`r",""

    # Register new certIficates with VMWare Lookup Service - KB2121701 and KB2121689.
    if ($pscDeployments -contains $deployment.DeployType) {
        # Register the new machine thumbprint with the lookup service.
        $commandList = $null
        $commandList = @()
        # Set path for python.
        $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandList += "export VMWARE_LOG_DIR=/var/log"
        $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandList += "export VMWARE_DATA_DIR=/storage"
        $commandList += "export VMWARE_JAVA_HOME=/usr/java/jre-vmware"
        # Register the new machine thumprint.
        $commandList += "python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $deployment.Hostname + "/lookupservice/sdk --fingerprint $thumbprint --certfile /root/ssl/new_machine.crt --user administrator@" + $deployment.SSODomainName + " --password `'" + $deployment.SSOAdminPass + "`'"

        Write-Output $commandList | Out-String
        $params = @{
            script = $commandList
            hostname = $deployment.Hostname
            credential = $credential
            viHandle = $viHandle
        }
        Invoke-ExecuteScript @params
    } else {
        # If the VCSA vCenter does not have an embedded PSC Register its Machine CertIficate with the External PSC.
        Write-Output $deploymentParent | Out-String
        # SCP the new vCenter machine certIficate to the external PSC and register it with the VMWare Lookup Service via SSH.
        $commandList = $null
        $commandList = @()
        $commandList += "sshpass -p `'" + $deploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $deploymentParent.Hostname + " mkdir /root/ssl"
        $commandList += "sshpass -p `'" + $deploymentParent.VCSARootPass + "`' scp -oStrictHostKeyChecking=no /root/ssl/new_machine.crt root@" + $deploymentParent.Hostname + ":/root/ssl/new_" + $deployment.Hostname + "_machine.crt"
        $commandList += "sshpass -p `'" + $deploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $deploymentParent.Hostname + " `"python /usr/lib/vmidentity/tools/scripts/ls_update_certs.py --url https://" + $deploymentParent.Hostname + "/lookupservice/sdk --fingerprint $thumbprint --certfile /root/ssl/new_" + $deployment.Hostname + "_machine.crt --user administrator@" + $deploymentParent.SSODomainName + " --password `'" + $deploymentParent.SSOAdminPass + "`'`""
        $commandList += "sshpass -p `'" + $deploymentParent.VCSARootPass + "`' ssh -oStrictHostKeyChecking=no root@" + $deploymentParent.Hostname + " rm -r /root/ssl"

        Write-Output $commandList | Out-String
        $params = @{
            script = $commandList
            hostname = $deployment.Hostname
            credential = $credential
            viHandle = $viHandle
        }
        Invoke-ExecuteScript @params
    }
}