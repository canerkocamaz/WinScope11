# WinScope 11 native module
[pscustomobject]@{
    Id                = 304
    Name              = 'NTLM Restriction Policy'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports NTLM incoming/outgoing restriction and audit settings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='MSV1_0 NTLM policy';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0';Names=@('RestrictSendingNTLMTraffic','RestrictReceivingNTLMTraffic','AuditReceivingNTLMTraffic','AuditNTLMInDomain')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'NTLM restrictions can break legacy authentication if changed without dependency analysis.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'NTLM restrictions can break legacy authentication if changed without dependency analysis.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'NTLM restrictions can break legacy authentication if changed without dependency analysis.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'NTLM restrictions can break legacy authentication if changed without dependency analysis.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'NTLM restrictions can break legacy authentication if changed without dependency analysis.' $null
                    }
                }
            }
        }
    }
}
