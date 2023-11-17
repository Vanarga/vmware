function Skip-SSLTrustIssues {
    <#
    .SYNOPSIS
        Save Object to json file.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-ToJson -InputObject < > -FilePath < >

        PS C:\> Save-Json

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Skip-SSLTrustIssues
    #>
    [CmdletBinding ()]
    Param ()

    # https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
    $NetAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

    if ($NetAssembly) {
        $BindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
        $SettingsType = $NetAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

        $Instance = $SettingsType.InvokeMember("Section", $BindingFlags, $null, $null, @())

        if ($Instance) {
            $BindingFlags = "NonPublic","Instance"
            $UseUnsafeHeaderParsingField = $SettingsType.GetField("useUnsafeHeaderParsing", $BindingFlags)

            if ($UseUnsafeHeaderParsingField) {
              $UseUnsafeHeaderParsingField.SetValue($Instance, $true)
            }
        }
    }
}