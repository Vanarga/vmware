function New-UserPEMFiles {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-UserPEMFiles

        PS C:\> New-UserPEMFiles

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-UserPEMFiles
    #>
    [cmdletbinding()]
    param()
    # Creates PEM files for all solution user certificates
    Get-ChildItem -Path $CertDir -Filter "*.csr" | ForEach-Object {
        $Dir = $_.Basename
        $params = @{
            SVCDir = $Dir
            CertFile = "$Dir.crt"
            CerFile = "$Dir.cer"
            CertDir = ""
            InstanceCertDir = ""
        }
        ConvertTo-PEMFormat @params
    }
}