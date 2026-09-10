# WinScope 11 native module
[pscustomobject]@{
    Id                = 331
    Name              = 'Windows FIPS Algorithm Policy'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports Windows system cryptography FIPS algorithm policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='FIPS policy';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy';Names=@('Enabled')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Crypto' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'FIPS policy affects cryptographic behavior and application compatibility; do not toggle casually.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Crypto' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'FIPS policy affects cryptographic behavior and application compatibility; do not toggle casually.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Crypto' $check.Item 'Info' ($pairs -join '; ') 'FIPS policy affects cryptographic behavior and application compatibility; do not toggle casually.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Crypto' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'FIPS policy affects cryptographic behavior and application compatibility; do not toggle casually.' $null
                    } else {
                        & $Context.NewFinding 'Crypto' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'FIPS policy affects cryptographic behavior and application compatibility; do not toggle casually.' $null
                    }
                }
            }
        }
    }
}
