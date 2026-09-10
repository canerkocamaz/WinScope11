# WinScope 11 native module
[pscustomobject]@{
    Id                = 330
    Name              = 'TLS Cipher Suite Order Policy'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports Group Policy configured SSL cipher suite order.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='SSL cipher suite order';Path='HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002';Names=@('Functions')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Schannel' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Cipher-suite policy can be domain-managed and should be changed only after compatibility testing.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Schannel' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Cipher-suite policy can be domain-managed and should be changed only after compatibility testing.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Schannel' $check.Item 'Info' ($pairs -join '; ') 'Cipher-suite policy can be domain-managed and should be changed only after compatibility testing.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Cipher-suite policy can be domain-managed and should be changed only after compatibility testing.' $null
                    } else {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Cipher-suite policy can be domain-managed and should be changed only after compatibility testing.' $null
                    }
                }
            }
        }
    }
}
