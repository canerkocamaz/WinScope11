# WinScope 11 native module
[pscustomobject]@{
    Id                = 335
    Name              = 'Trusted Root Auto Update Policy'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports policy controlling automatic root certificate updates.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Root auto update';Path='HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\AuthRoot';Names=@('DisableRootAutoUpdate')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Crypto' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Trusted root update policy affects certificate trust freshness and can be centrally managed.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Crypto' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Trusted root update policy affects certificate trust freshness and can be centrally managed.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Crypto' $check.Item 'Info' ($pairs -join '; ') 'Trusted root update policy affects certificate trust freshness and can be centrally managed.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Crypto' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Trusted root update policy affects certificate trust freshness and can be centrally managed.' $null
                    } else {
                        & $Context.NewFinding 'Crypto' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Trusted root update policy affects certificate trust freshness and can be centrally managed.' $null
                    }
                }
            }
        }
    }
}
