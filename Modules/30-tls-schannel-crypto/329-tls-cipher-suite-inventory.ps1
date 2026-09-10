# WinScope 11 native module
[pscustomobject]@{
    Id                = 329
    Name              = 'TLS Cipher Suite Inventory'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports TLS cipher suites available to Windows Schannel.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd = Get-Command Get-TlsCipherSuite -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Schannel' 'TLS cipher suites' 'Unavailable' 'Get-TlsCipherSuite is not available in this PowerShell/Windows environment.' 'Cipher suite availability depends on Windows build and cryptographic policy.' $null
        } else {
            $suites = @(Get-TlsCipherSuite -ErrorAction SilentlyContinue)
            if($suites.Count -eq 0) {
                & $Context.NewFinding 'Schannel' 'TLS cipher suites' 'NoData' 'No cipher suites were returned.' 'Review local or domain TLS policy.' $null
            } else {
                $index=0
                foreach($s in $suites) {
                    $index++
                    & $Context.NewFinding 'Schannel' ("Cipher #{0}" -f $index) 'Info' ("Name={0}; Exchange={1}; Cipher={2}; Hash={3}" -f $s.Name,$s.Exchange,$s.Cipher,$s.Hash) 'Cipher-suite ordering and availability should follow the organization security baseline.' $null
                }
            }
        }
    }
}
