function Skip-SslTrustIssues {
    <#
    .SYNOPSIS
        Ignoring SSL trust in PowerShell System.Net.WebClient.

    .DESCRIPTION
        Ignoring SSL trust in PowerShell System.Net.WebClient

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Skip-SslTrustIssues

        PS C:\> Skip-SslTrustIssues

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Skip-SslTrustIssues
    #>
    [CmdletBinding ()]
    Param ()

    # https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
    $netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

    if ($netAssembly) {
        $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
        $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

        $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

        if ($instance) {
            $bindingFlags = "NonPublic","Instance"
            $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

            if ($useUnsafeHeaderParsingField) {
              $useUnsafeHeaderParsingField.SetValue($instance, $true)
            }
        }
    }
}