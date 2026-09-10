# WinScope 11 native module
[pscustomobject]@{
    Id                = 332
    Name              = 'Schannel Event Logging Policy'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports Schannel event logging configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Schannel event logging';Path='HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL';Names=@('EventLogging')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Schannel' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Schannel event logging can aid TLS troubleshooting; excessive logging may add noise.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Schannel' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Schannel event logging can aid TLS troubleshooting; excessive logging may add noise.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Schannel' $check.Item 'Info' ($pairs -join '; ') 'Schannel event logging can aid TLS troubleshooting; excessive logging may add noise.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Schannel event logging can aid TLS troubleshooting; excessive logging may add noise.' $null
                    } else {
                        & $Context.NewFinding 'Schannel' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Schannel event logging can aid TLS troubleshooting; excessive logging may add noise.' $null
                    }
                }
            }
        }
    }
}
