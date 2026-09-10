# WinScope 11 native module
[pscustomobject]@{
    Id                = 309
    Name              = 'Remote Credential Guard Policy'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports policy values associated with Restricted Admin / Remote Credential Guard behavior.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Credentials Delegation';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation';Names=@('RestrictedRemoteAdministration')},
            @{Item='LSA Restricted Admin';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Names=@('DisableRestrictedAdmin')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Remote Credential Guard and Restricted Admin behavior should be aligned with RDP administration requirements.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Remote Credential Guard and Restricted Admin behavior should be aligned with RDP administration requirements.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Remote Credential Guard and Restricted Admin behavior should be aligned with RDP administration requirements.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Remote Credential Guard and Restricted Admin behavior should be aligned with RDP administration requirements.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Remote Credential Guard and Restricted Admin behavior should be aligned with RDP administration requirements.' $null
                    }
                }
            }
        }
    }
}
