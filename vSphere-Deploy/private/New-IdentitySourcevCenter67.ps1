function New-IdentitySourcevCenter67 {
    .SYNOPSIS
		Configure Identity Source - Add AD domain as Native for SSO, Add AD group to Administrator permissions on SSO.

    .DESCRIPTION

    .PARAMETER Deployment

    .PARAMETER ADInfo

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-IdentitySourcevCenter67 -Deployment < > -ADInfo < >

        PS C:\> New-IdentitySourcevCenter67

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-IdentitySourcevCenter67
    #>
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Deployment,
		[Parameter(Mandatory=$true)]
		$ADInfo
	)

	# Add AD domain as Native Identity Source.
	Write-Output "============ Adding AD Domain as Identity Source for SSO on vCenter Instance 6.7 ============" | Out-String

	Get-URLStatus $("https://" + $Deployment.Hostname + "/ui/")

	Start-Sleep -Seconds 10

	# Get list of existing Internet Explorer instances.
	$instances = Get-Process -Name iexplore -erroraction silentlycontinue

	$ie = New-Object -com InternetExplorer.Application

	$ie.Visible = $false

	$uri = "https://" + $Deployment.Hostname + "/ui/"

	Do {
		$ie.Navigate($uri)

		while($ie.ReadyState -ne 4) {Start-Sleep -m 100}

		while($ie.Document.ReadyState -ne "complete") {Start-Sleep -m 100}

		Write-Output $ie.Document.url | Out-String

		Start-Sleep -Seconds 30

	} Until ($ie.Document.url -match "websso")

	Write-Output "ie" | Out-String
	Write-Output $ie | Out-String

	Write-SeparatorLine

	Start-Sleep 1

	$ie.Document.DocumentElement.GetElementsByClassName("margeTextInput")[0].value = 'administrator@' + $Deployment.SSODomainName
	$ie.Document.DocumentElement.GetElementsByClassName("margeTextInput")[1].value = $Deployment.SSOAdminPass

	Start-Sleep 1

	# Enable the submit button and click it.
	$ie.Document.DocumentElement.GetElementsByClassName("button blue")[0].Disabled = $false
	$ie.Document.DocumentElement.GetElementsByClassName("button blue")[0].click()

	Start-Sleep 10

	$uri = "https://" + $Deployment.Hostname + "/ui/#?extensionId=vsphere.core.administration.configurationView"

	$ie.Navigate($uri)

	Start-Sleep 1

	($ie.Document.DocumentElement.getElementsByClassName('btn btn-link nav-link nav-item') | Where-Object {$_.id -eq 'clr-tab-link-3'}).click()

	Start-Sleep 1

	($ie.Document.DocumentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'addNewIdentity'}).click()

	Start-Sleep 1

	$ie.Document.DocumentElement.getElementsByClassName('btn btn-primary')[0].click()

	Start-Sleep 1

	$selections = ($ie.Document.DocumentElement.getElementsByTagName("clr-dg-cell") | Select-Object outertext).outertext -replace " ",""
	$row =  0..2 | Where-Object {$selections[1,7,13][$_] -eq $ADInfo.ADDomain}

	$ie.Document.DocumentElement.getElementsByClassName("radio")[$row].childnodes[3].click()

	($ie.Document.DocumentElement.getElementsByClassName('btn btn-link') | Where-Object {$_.getAttributeNode('role').Value -eq 'defaultIdentity'}).click()

	Start-Sleep 1

	$ie.Document.DocumentElement.getElementsByClassName('btn btn-primary')[0].click()

	# Exit Internet Explorer.
	$ie.quit()

	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($ie)

	$ie = $null

	# Get a list of the new Internet Explorer Instances and close them, leaving the old instances running.
	$newInstances = Get-Process -Name iexplore
	$newInstances | Where-Object {$instances.id -notcontains $_.id} | Stop-Process

	Write-Output "============ Completed adding AD Domain as Identity Sourcefor SSO on PSC ============" | Out-String
}