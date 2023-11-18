function New-AutoDeployRule {
    <#
    .SYNOPSIS
        Configure the Autodeploy Service - set auto start, register vCenter, and start service.

    .DESCRIPTION
        Configure the Autodeploy Service - set auto start, register vCenter, and start service.

    .PARAMETER Rules
        The mandatory array of PSObjects parameter Rules are all the autodeploy rules that will be applied.

    .PARAMETER Path
        The mandatory string parameter Path is the location of the host profile file to import.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-AutoDeployRule -Rules <PSObject Array>
                           -Path <String>
                           -ViHandle <VI Session>

        PS C:\> New-AutoDeployRule

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-AutoDeployRule
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$Rules,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$Path,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-Output $Rules | Out-String

    # Turn off signature check - needed to avoid errors from unsigned packages/profiles.
    #$DeployNoSignatureCheck = $true

    ForEach ($rule in $Rules) {
        $hostProfExport = $Path + "\" + $rule.ProfileImport

        $si = Get-View -Server $ViHandle ServiceInstance
        $hostProfMgr = Get-View -Server $ViHandle -Id $si.Content.HostProfileManager

        $spec = New-Object -TypeName VMware.Vim.HostProfileSerializedHostProfileSpec
        $spec.Name = $rule.ProfileName
        $spec.Enabled = $true
        $spec.Annotation = $rule.ProfileAnnotation
        $spec.Validating = $false
        $spec.ProfileConfigString = (Get-Content -Path $hostProfExport)

        $hostProfMgr.CreateProfile($spec)

        Write-Output -InputObject $hostProfMgr | Out-String

        # Add offline bundles to depot
        $depotPath = $Path + "\" + $rule.SoftwareDepot
        Add-EsxSoftwareDepot -DepotUrl $depotPath

        # Create a new deploy rule.
        $img = Get-EsxImageProfile | Where-Object {$rule.SoftwareDepot.Substring(0,$rule.SoftwareDepot.Indexof(".zip"))}
        if ($img.count -gt 1) {
            $img = $img[1]
        }
        Write-Output -InputObject $img | Out-String

        $pro = Get-VMHostProfile -Server $ViHandle | Where-Object {$_.Name -eq $rule.ProfileName}
        Write-Output -InputObject $pro | Out-String

        $clu = Get-Datacenter -Server $ViHandle -Name $rule.Datacenter | Get-Cluster -Name $rule.Cluster
        Write-Output $clu | Out-String

        Write-Output -InputObject "New-DeployRule -Name $($rule.RuleName) -Item $img, $pro, $clu -Pattern $($rule.Pattern)" | Out-String
        New-DeployRule -Name $rule.RuleName -Item $img, $pro, $clu -Pattern $rule.Pattern -ErrorAction SilentlyContinue

        # Activate the deploy rule.
        Add-DeployRule -DeployRule $rule.RuleName -ErrorAction SilentlyContinue
    }
}