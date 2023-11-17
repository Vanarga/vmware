<#
    .NOTES
    ===========================================================================
     Created by:    Michael van Blijdesteijn
    ===========================================================================
    .DESCRIPTION
        This script configure a autodeploy reverse proxy from an existing Photon OS 2.0 VM.
        The VM must have already been deployed and have a static DNS entry, but does not need any configurations.
    .PARAMETER Deployment
        FQDN of proxy sever. e.g. reverse-proxy.acme.com
    .PARAMETER Username
        AD Credential with permission on vCenter and ability to connect to Certificate Authority.
    .PARAMETER IP
        IP address for the proxy server you are deploying.
    .PARAMETER NetMask
        Netmask in bits for proxy server. e.g. 24 or 28 etc.
    .PARAMETER Gateway
        Network Gateway of subnet for proxy server.
    .PARAMETER rootpassword
        New root password for proxy server.
    .EXAMPLE
        Configure Reverse Proxy.ps1 -Deployment reverse-proxy.acme.com -Username <AD Username> -Password '<AD Password>' -IP 10.10.10.100 -NetMask 24 -Gateway 10.10.10.1 -rootpassword '<New Password>'
#>

# Script input parameters.
[cmdletbinding()]
param (
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string]$Deployment,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [SecureString]$Credential,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string]$IP,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string]$NetMask,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string]$Gateway,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [SecureString]$RootCredential,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string]$vCenter
)

function CopyFiletoServer {
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Locations,
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
        $ViHandle,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Upload
    )

    For ($i=0; $i -le ($Locations.count/2)-1;$i++) {
        Write-Host -Object "Sources: `n"
        Write-Output -InputObject $Locations[$i*2] | Out-String
        Write-Host -Object "Destinations: `n"
        Write-Output -InputObject $Locations[($i*2)+1] | Out-String
        if ($Upload) {
			$params = @{
				VM = $Hostname
				LocalToGuest = $true
				Source = $Locations[$i*2]
				Destination = $Locations[($i*2)+1]
				GuestUser = $Credential.Username
				GuestPassword = $Credential.GetNetworkCredential().password
				Server = $ViHandle
				Force = $true
			}
			Copy-VMGuestFile @params
		} else {
			$params = @{
				VM = $Hostname
				GuestToLocal = $true
				Source = $Locations[$i*2]
				Destination = $Locations[($i*2)+1]
				GuestUser = $Credential.Username
				GuestPassword = $Credential.GetNetworkCredential().password
				Server = $ViHandle
				Force = $true
			}
            Copy-VMGuestFile @params
        }
    }
}

function ExecuteScript {
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Script,
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

	$Script | ForEach-Object {Write-Output $_} | Out-String
	$params = @{
		ScriptText = if ($Script.count -gt 1) {$Script -join(";")} else {$Script}
		VM = $Hostname
		GuestUser = $Credential.Username
		GuestPassword = $Credential.GetNetworkCredential().password
		Server = $ViHandle
	}
    return Invoke-VMScript @params
}

Function Set-VMKeystrokes {
<#
    .NOTES
    ===========================================================================
     Created by:    William Lam
     Organization:  VMware
     Blog:          www.virtuallyghetto.com
     Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function sends a series of character keystrokse to a particular VM
    .PARAMETER VMName
        The name of a VM to send keystrokes to
    .PARAMETER StringInput
        The string of characters to send to VM
    .PARAMETER DebugOn
        Enable debugging which will output input charcaters and their mappings
    .EXAMPLE
        Set-VMKeystrokes -VMName $VM -StringInput "root"
    .EXAMPLE
        Set-VMKeystrokes -VMName $VM -StringInput "root" -ReturnCarriage $true
    .EXAMPLE
        Set-VMKeystrokes -VMName $VM -StringInput "root" -DebugOn $true
#>
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$VMName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$StringInput,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Boolean]$ReturnCarriage,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Boolean]$DebugOn
    )

    # Map subset of USB HID keyboard scancodes
    # https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2
    $hidCharacterMap = @{
        "a"="0x04";
        "b"="0x05";
        "c"="0x06";
        "d"="0x07";
        "e"="0x08";
        "f"="0x09";
        "g"="0x0a";
        "h"="0x0b";
        "i"="0x0c";
        "j"="0x0d";
        "k"="0x0e";
        "l"="0x0f";
        "m"="0x10";
        "n"="0x11";
        "o"="0x12";
        "p"="0x13";
        "q"="0x14";
        "r"="0x15";
        "s"="0x16";
        "t"="0x17";
        "u"="0x18";
        "v"="0x19";
        "w"="0x1a";
        "x"="0x1b";
        "y"="0x1c";
        "z"="0x1d";
        "1"="0x1e";
        "2"="0x1f";
        "3"="0x20";
        "4"="0x21";
        "5"="0x22";
        "6"="0x23";
        "7"="0x24";
        "8"="0x25";
        "9"="0x26";
        "0"="0x27";
        "!"="0x1e";
        "@"="0x1f";
        "#"="0x20";
        "$"="0x21";
        "%"="0x22";
        "^"="0x23";
        "&"="0x24";
        "*"="0x25";
        "("="0x26";
        ")"="0x27";
        "_"="0x2d";
        "+"="0x2e";
        "{"="0x2f";
        "}"="0x30";
        "|"="0x31";
        ":"="0x33";
        "`""="0x34";
        "~"="0x35";
        "<"="0x36";
        ">"="0x37";
        "?"="0x38";
        "-"="0x2d";
        "="="0x2e";
        "["="0x2f";
        "]"="0x30";
        "\"="0x31";
        "`;"="0x33";
        "`'"="0x34";
        ","="0x36";
        "."="0x37";
        "/"="0x38";
        " "="0x2c";
    }

    $params = @{
        ViewType = "VirtualMachine"
        Filter = @{"Name" = $VMName}
    }
    $VM = Get-View @params

    # Verify we have a VM or fail
    if (-not $vm) {
        Write-Host -Object "Unable to find VM $VMName"
        return
    }

    $hidCodesEvents = @()
    ForEach ($character in $StringInput.ToCharArray()) {
        # Check to see if we've mapped the character to HID code
        if ($hidCharacterMap.ContainsKey([string]$character)) {
            $hidCode = $hidCharacterMap[[string]$character]

            $tmp = New-Object -TypeName VMware.Vim.UsbScanCodeSpecKeyEvent

            # Add leftShift modifer for capital letters and/or special characters
            if (($character -cmatch "[A-Z]") -or ($character -match "[!|@|#|$|%|^|&|(|)|_|+|{|}|||:|~|<|>|?|*]") ) {
                $modifer = New-Object -TypeName Vmware.Vim.UsbScanCodeSpecModifierType
                $modifer.LeftShift = $true
                $tmp.Modifiers = $modifer
            }

            # Convert to expected HID code format
            $hidCodeHexToInt = [Convert]::ToInt64($hidCode,"16")
            $hidCodeValue = ($hidCodeHexToInt -shl 16) -bor 0007

            $tmp.UsbHidCode = $hidCodeValue
            $hidCodesEvents += $tmp

            if ($DebugOn) {
                Write-Host -Object "Character: $character -> HIDCode: $hidCode -> HIDCodeValue: $hidCodeValue"
            }
        } else {
            Write-Host -Object "The following character `"$character`" has not been mapped, you will need to manually process this character"
            break
        }
    }

    # Add return carriage to the end of the string input (useful for logins or executing commands)
    if ($ReturnCarriage) {
        # Convert return carriage to HID code format
        $hidCodeHexToInt = [Convert]::ToInt64("0x28","16")
        $hidCodeValue = ($hidCodeHexToInt -shl 16) + 7

        $tmp = New-Object -TypeName VMware.Vim.UsbScanCodeSpecKeyEvent
        $tmp.UsbHidCode = $hidCodeValue
        $hidCodesEvents += $tmp
    }

    # Call API to send keystrokes to VM
    $spec = New-Object -TypeName Vmware.Vim.UsbScanCodeSpec
    $spec.KeyEvents = $hidCodesEvents
    Write-Host -Object "Sending keystrokes to $VMName ...`n"
    $results = $vm.PutUsbScanCodes($spec)
}

# Connect to vCenter.
$params = @{
    Server = $vCenter
    Credential = $Credential
}
$ViHandle = Connect-VIServer @params

# Log in as root and change the password.
$params = @{
    VMName = $Deployment
    StringInput = "root"
    $ReturnCarriage = $true
}
Set-VMKeystrokes @params
$params = @{
    VMName = $Deployment
    StringInput = "changeme"
    $ReturnCarriage = $true
}
Set-VMKeystrokes @params
$params = @{
    VMName = $Deployment
    StringInput = "changeme"
    $ReturnCarriage = $true
}
Set-VMKeystrokes @params
$params = @{
    VMName = $Deployment
    StringInput = $rootpassword
    $ReturnCarriage = $true
}
Set-VMKeystrokes @params
$params = @{
    VMName = $Deployment
    StringInput = $rootpassword
    $ReturnCarriage = $true
}
Set-VMKeystrokes @params

# Wait for vmware tools to start.
While ((Get-VM -Name $Deployment).ExtensionData.Guest.ToolsStatus -ne "toolsOk")
    {Start-Sleep -Seconds 10}

# need to wait another minute for vmware tools to be functional inside the vm.
Start-Sleep -Seconds 60

# load the configuration file script and format for unix by replacing the `r`n with `n and saving it.
$File = Get-Content -Raw -Path $((Get-Location).Path + "\config.sh")
$File -replace "`r`n","`n" | Set-Content -Path $((Get-Location).Path + "\config.sh") -Force

# Copy the config.sh shell script to the server via vmware tools.
$FileLocations = $null
$FileLocations = @()
$FileLocations += (Get-Location).Path + "\config.sh"
$FileLocations += "/root/config.sh"

$params = @{
    $Locations = $FileLocations
    $Hostname = $Deployment
    $Credential = $RootCredential
    $ViHandle = $ViHandle
    $Upload = $true
}
CopyFiletoServer @params

#$Script = Get-Content $((Get-Location).Path + "\config.sh")

# Set the config.sh file to be executable on the server and run with arguments below.
$CommandList = $null
$CommandList = @()
$CommandList += 'chmod 777 config.sh'
$CommandList += "/usr/bin/script -c `"/root/config.sh " + $Credential.Username + " `'" + $Credential.GetNetworkCredential().Password + "`' " + $Deployment + " " + $IP + " " + $NetMask + " " + $Gateway + "`" /root/output.log"

# Excute the commands in $CommandList on the vcsa.
$params = @{
    Script = $CommandList
    Hostname = $Deployment
    Credential = $RootCredential
    ViHandle = $ViHandle
}
ExecuteScript @params

# Send via VMKeystrokes command to update packages. This reinstalls vmware tools so it cannot be done via ExecuteScript.
$params = @{
    VMName = $Deployment
    StringInput = "time tdnf -y distro-sync"
    ReturnCarriage = $true
}
Set-VMKeystrokes @params

# Wait for tdnf to finish updating. ~3 min.
Start-Sleep -Seconds 180

# reboot the server.
Get-VM -Name $Deployment | Restart-VMGuest -Confirm:$false

# Set the ServerAddress to be added to vCenter as a Proxy Server for Auto Deploy.
$ServerAddress = "http://" + $Deployment + ":5100"

# Add the server as a proxy server and check to see that it is listed.
Add-ProxyServer -Address $ServerAddress
Get-ProxyServer

# Disconnect from vCenter.
Disconnect-VIServer $ViHandle -Confirm:$false