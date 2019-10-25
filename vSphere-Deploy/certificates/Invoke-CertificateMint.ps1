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
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$SVCDir,
		[Parameter(Mandatory=$true)]
		$CSRFile,
		[Parameter(Mandatory=$true)]
		$CertFile,
		[Parameter(Mandatory=$true)]
		$Template,
		[Parameter(Mandatory=$true)]
		$CertDir,
		[Parameter(Mandatory=$true)]
		$IssuingCA
	)

    # initialize objects to use for external processes
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $psi
    $script:certsWaitingForApproval = $false
        # submit the CSR to the CA
        $psi.FileName = "certreq.exe"
        $psi.Arguments = @("-submit -attrib `"$Template`" -config `"$IssuingCA`" -f `"$CertDir\$SVCDir\$CSRFile`" `"$CertDir\$SVCDir\$CertFile`"")
		Write-Host ""
        Write-Host "Submitting certificate request for $SVCDir..." -ForegroundColor Yellow
        [void]$Process.Start()
        $cmdOut = $Process.StandardOutput.ReadToEnd()
        if ($cmdOut.Trim() -like "*request is pending*") {
            # Output indicates the request requires approval before we can download the signed cert.
            $script:certsWaitingForApproval = $true
            # So we need to save the request ID to use later once they're approved.
            $reqID = ([regex]"RequestId: (\d+)").Match($cmdOut).Groups[1].Value
            if ($reqID.Trim() -eq [String]::Empty) {
                Write-Error "Unable to parse RequestId from output."
                Write-Debug $cmdOut
                exit
            }
            Write-Host "RequestId: $reqID is pending" -ForegroundColor Yellow
            # Save the request ID to a file that Invoke-CertificateMintResume can read back in later
            $reqID | Out-File "$CertDir\$SVCDir\requestid.txt"
        } else {
            # Output doesn't indicate a pending request, so check for a signed cert file
            if (-not(Test-Path $CertDir\$SVCDir\$CertFile)) {
                Write-Error "Certificate request failed or was unable to download the signed certificate."
                Write-Error "Verify that the ISSUING_CA variable is set correctly."
                Write-Debug $cmdOut
                exit
            } else {
				Write-Host "Certificate successfully downloaded." -ForegroundColor Yellow
			}
        }
    if ($script:certsWaitingForApproval) {
        Write-Host
        Write-Host "One or more certificate requests require manual approval before they can be downloaded." -ForegroundColor Yellow
        Write-Host "Contact your CA administrator to approve the request ID(s) listed above." -ForegroundColor Yellow
        Write-Host "To resume use the appropriate option from the menu." -ForegroundColor Yellow
    }
}