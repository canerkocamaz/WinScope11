# WinScope 11 native module
[pscustomobject]@{
    Id                = 324
    Name              = 'TLS 1.1 Server Policy'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports Schannel TLS 1.1 server protocol policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='TLS 1.1 Server';Path='HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server';Names=@('Enabled','DisabledByDefault')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Schannel' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Protocol policy should be interpreted together with application compatibility and organization security baselines.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Schannel' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Protocol policy should be interpreted together with application compatibility and organization security baselines.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Schannel' $check.Item 'Info' ($pairs -join '; ') 'Protocol policy should be interpreted together with application compatibility and organization security baselines.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Protocol policy should be interpreted together with application compatibility and organization security baselines.' $null
                    } else {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Protocol policy should be interpreted together with application compatibility and organization security baselines.' $null
                    }
                }
            }
        }
    }
}
