# WinScope 11 native module
[pscustomobject]@{
    Id                = 336
    Name              = 'Cryptographic Service Provider Inventory'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports registered legacy Cryptographic Service Providers.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root='HKLM:\SOFTWARE\Microsoft\Cryptography\Defaults\Provider'
        if(-not (Test-Path -LiteralPath $root)) {
            & $Context.NewFinding 'Crypto' 'Legacy crypto providers' 'NotFound' ("Registry path not present: {0}" -f $root) 'Provider inventory is informational.' $null
        } else {
            $providers=@(Get-ChildItem -LiteralPath $root -ErrorAction SilentlyContinue)
            foreach($p in $providers) {
                & $Context.NewFinding 'Crypto' $p.PSChildName 'Info' ("Registry={0}" -f $p.Name) 'Legacy CSP providers may remain for application compatibility.' $null
            }
        }
    }
}
