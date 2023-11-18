function Invoke-CertificateMintResume {
    <#
    .SYNOPSIS
        Resume the minting process for certificates from online Microsoft CA that required approval.

    .DESCRIPTION
        Resume the minting process for certificates from online Microsoft CA that required approval.

    .PARAMETER SvcDir
        The mandatory string parameter SvcDir is the vmware service directory name and is used for the subfolder to place the certficates in.

    .PARAMETER CertFile
        The mandatory string parameter CertFile is the certificate filename.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-CertificateMintResume -SvcDir <String>
                                     -CertFile <String>

        PS C:\> Invoke-CertificateMintResume

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-CertificateMintResume
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$SvcDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertFile
    )

    # initialize objects to use for external processes
    $psi = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo = $psi
    $script:certsWaitingForApproval = $false
    # skip if there's no requestid.txt file
    if (-not(Test-Path -Path "$CertDir\$SvcDir\requestid.txt")) {continue}
    $reqID = Get-Content -Path "$CertDir\$SvcDir\requestid.txt"
    Write-Verbose -Message "Found RequestId: $reqID for $SvcDir"
    # retrieve the signed certificate
    $psi.FileName = "certreq.exe"
    $psi.Arguments = @("-retrieve -f -config `"$IssuingCa`" $reqID `"$CertDir\$SvcDir\$CertFile`"")
    Write-Host -Object "Downloading the signed $SvcDir certificate..." -ForegroundColor Yellow
    [void]$process.Start()
    $cmdOut = $process.StandardOutput.ReadToEnd()
    if (-not(Test-Path -Path "$CertDir\$SvcDir\$CertFile")) {
        # it's not there, so check if the request is still pending
        if ($cmdOut.Trim() -like "*request is pending*") {
            $script:certsWaitingForApproval = $true
            Write-Host -Object "RequestId: $reqID is pending" -ForegroundColor Yellow
        } else {
            Write-Warning -Message "There was a problem downloading the signed certificate" -Foregroundcolor red
            Write-Warning -Message $cmdOut
            continue
        }
    }
    if ($script:certsWaitingForApproval) {
        Write-Host -Object ""
        Write-Host -Object "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host -Object "Contact your CA administrator to approve the request IDs listed above." -ForegroundColor Yellow
    }
    $script:certsWaitingForApproval = $false
}