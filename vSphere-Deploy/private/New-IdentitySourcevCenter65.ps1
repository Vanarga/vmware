function New-IdentitySourcevCenter65 {
    <#
    .SYNOPSIS
        Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.

    .DESCRIPTION

    .PARAMETER Deployment

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-IdentitySourcevCenter65 -Deployment < >

        PS C:\> New-IdentitySourcevCenter65

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-IdentitySourcevCenter65
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Deployment
    )

    # Add AD domain as Native Identity Source.
    Write-Output -InputObject "============ Adding AD Domain as Identity Source for SSO on PSC Instance 6.5 ============" | Out-String

    Start-Sleep -Seconds 10

    # Get list of existing Internet Explorer instances.
    $instances = Get-Process -Name iexplore -ErrorAction SilentlyContinue

    # Create new Internet Explorer instance.
    $ie = New-Object -ComObject InternetExplorer.Application

    # Don't make the Internet Explorer instance visible.
    $ie.Visible = $false

    # Navigate to https://<fqdn of host>/psc/
    $ie.Navigate($("https://" + $Deployment.Hostname + "/psc/"))

    # Wait while page finishes loading.
    while ($ie.ReadyState -ne 4) {
        Start-Sleep -Milliseconds 100
    }
    while ($ie.Document.ReadyState -ne "complete") {
        Start-Sleep -Milliseconds 100
    }

    Write-SeparatorLine

    Write-Output -InputObject "ie" | Out-String
    Write-Output -InputObject $ie | Out-String

    Write-SeparatorLine

    # Fill in the username and password fields with the SSO Administrator credentials.
    $ie.Document.DocumentElement.getElementsByClassName('margeTextInput')[0].value = 'administrator@' + $Deployment.SSODomainName
    $ie.Document.DocumentElement.getElementsByClassName('margeTextInput')[1].value = $Deployment.SSOAdminPass

    # Enable the submit button and click it.
    $ie.Document.DocumentElement.getElementsByClassName('button blue')[0].Disabled = $false
    $ie.Document.DocumentElement.getElementsByClassName('button blue')[0].click()

    Start-Sleep -Seconds 10

    # Navigate to the add Identity Sources page for the SSO.
    $ie.Navigate("https://" + $Deployment.Hostname + "/psc/#?extensionId=sso.identity.sources.extension")

    Write-Output -InputObject $ie | Out-String

    Start-Sleep -Seconds 1

    # Select the Add Identity Source button and click it.
    $ca = $ie.Document.DocumentElement.getElementsByClassName('vui-action-label ng-binding ng-scope') | Select-Object -first 1
    $ca.click()

    Start-Sleep -Seconds 1

    # Click the Active Directory Type Radio button.
    $ie.Document.DocumentElement.getElementsByClassName('ng-pristine ng-untouched ng-valid')[0].click()

    Start-Sleep -Seconds 1

    # Click OK.
    $ca = $ie.Document.DocumentElement.getElementsByClassName('ng-binding') | Where-Object {$_.innerHTML -eq "OK"}
    $ca.click()

    # Exit Internet Explorer.
    $ie.quit()

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ie)

    $ca = $null
    $ie = $null

    # Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
    $newInstances = Get-Process -Name iexplore -ErrorAction SilentlyContinue
    $newInstances | Where-Object {$instances.id -notcontains $_.id} | Stop-Process

    Write-Output -InputObject "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String
}