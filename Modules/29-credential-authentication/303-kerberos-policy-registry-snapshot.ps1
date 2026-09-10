# WinScope 11 native module
[pscustomobject]@{
    Id                = 303
    Name              = 'Kerberos Policy Registry Snapshot'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports selected local Kerberos policy registry values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Kerberos parameters';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters';Names=@('SupportedEncryptionTypes','MaxPacketSize','LogLevel')},
            @{Item='Kerberos policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters';Names=@('SupportedEncryptionTypes')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Kerberos settings may be domain-managed; absence of a local value does not imply a weak configuration.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Kerberos settings may be domain-managed; absence of a local value does not imply a weak configuration.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Kerberos settings may be domain-managed; absence of a local value does not imply a weak configuration.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Kerberos settings may be domain-managed; absence of a local value does not imply a weak configuration.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Kerberos settings may be domain-managed; absence of a local value does not imply a weak configuration.' $null
                    }
                }
            }
        }
    }
}
