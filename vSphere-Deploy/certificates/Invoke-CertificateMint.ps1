function Invoke-CertificateMint {
    <#
    .SYNOPSIS
        Mint certificates from online Microsoft CA.

    .DESCRIPTION

    .PARAMETER SVCDir

    .PARAMETER CSRFile

    .PARAMETER CertFile

    .PARAMETER Template

    .PARAMETER CertDir

    .PARAMETER IssuingCA

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-CertificateMint -SVCDir < > -CSRFile < > -CertFile < > -Template < > -CertDir < > -IssuingCA < >

        PS C:\> Invoke-CertificateMint

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-CertificateMint
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $servicePath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $csrFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $template,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $issuingCA
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
        # submit the CSR to the CA
        $psi.FileName = "certreq.exe"
        $psi.Arguments = @("-submit -attrib `"$template`" -config `"$issuingCA`" -f `"$certPath\$servicePath\$csrFile`" `"$certPath\$servicePath\$certFile`"")
        Write-Host -Object ""
        Write-Host -Object "Submitting certificate request for $servicePath..." -ForegroundColor Yellow
        [void]$process.Start()
        $cmdOut = $process.StandardOutput.ReadToEnd()
        if ($cmdOut.Trim() -like "*request is pending*") {
            # Output indicates the request requires approval before we can download the signed cert.
            $script:certsWaitingForApproval = $true
            # So we need to save the request ID to use later once they're approved.
            $reqID = ([regex]"RequestId: (\d+)").Match($cmdOut).Groups[1].Value
            if ($reqID.Trim() -eq [String]::Empty) {
                Write-Error -Message "Unable to parse RequestId from output."
                Write-Debug -Message $cmdOut
                exit
            }
            Write-Host -Object "RequestId: $reqID is pending" -ForegroundColor Yellow
            # Save the request ID to a file that Invoke-CertificateMintResume can read back in later
            $reqID | Out-File -FilePath "$certPath\$servicePath\requestid.txt"
        } else {
            # Output doesn't indicate a pending request, so check for a signed cert file
            if (-not(Test-Path -Path "$certPath\$servicePath\$certFile")) {
                Write-Error -Message "Certificate request failed or was unable to download the signed certificate."
                Write-Error -Message "Verify that the ISSUING_CA variable is set correctly."
                Write-Debug -Message $cmdOut
                exit
            } else {
                Write-Host -Object "Certificate successfully downloaded." -ForegroundColor Yellow
            }
        }
    if ($script:certsWaitingForApproval) {
        Write-Host -Object ""
        Write-Host -Object "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host -Object "Contact your CA administrator to approve the request ID(s) listed above." -ForegroundColor Yellow
        Write-Host -Object "To resume use the appropriate option from the menu." -ForegroundColor Yellow
    }
}