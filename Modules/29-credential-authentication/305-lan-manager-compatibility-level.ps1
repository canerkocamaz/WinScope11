# WinScope 11 native module
[pscustomobject]@{
    Id                = 305
    Name              = 'LAN Manager Compatibility Level'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports LmCompatibilityLevel used by Windows authentication compatibility policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='LSA authentication compatibility';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Names=@('LmCompatibilityLevel')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Higher compatibility levels reduce use of legacy LM/NTLM protocols, but enterprise dependencies must be evaluated.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Higher compatibility levels reduce use of legacy LM/NTLM protocols, but enterprise dependencies must be evaluated.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Higher compatibility levels reduce use of legacy LM/NTLM protocols, but enterprise dependencies must be evaluated.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Higher compatibility levels reduce use of legacy LM/NTLM protocols, but enterprise dependencies must be evaluated.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Higher compatibility levels reduce use of legacy LM/NTLM protocols, but enterprise dependencies must be evaluated.' $null
                    }
                }
            }
        }
    }
}
