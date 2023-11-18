function New-UserPemFiles {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-UserPemFiles

        PS C:\> New-UserPemFiles

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-UserPemFiles
    #>
    [CmdletBinding ()]
    Param ()
    # Creates PEM files for all solution user certificates
    Get-ChildItem -Path $CertDir -Filter "*.csr" | ForEach-Object {
        $path = $_.Basename
        $params = @{
            ServicePath = $path
            CertFile = "$path.crt"
            CerFile = "$path.cer"
            CertDir = ""
            InstanceCertDir = ""
        }
        ConvertTo-PEMFormat @params
    }
}