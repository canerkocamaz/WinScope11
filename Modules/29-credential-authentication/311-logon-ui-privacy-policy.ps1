# WinScope 11 native module
[pscustomobject]@{
    Id                = 311
    Name              = 'Logon UI Privacy Policy'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports selected Windows logon UI privacy and user enumeration settings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Logon UI policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';Names=@('DontDisplayLastUserName','DontDisplayLockedUserId','EnumerateLocalUsers','BlockUserFromShowingAccountDetailsOnSignin')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Logon UI settings affect information disclosure and user experience at sign-in.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Logon UI settings affect information disclosure and user experience at sign-in.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Logon UI settings affect information disclosure and user experience at sign-in.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Logon UI settings affect information disclosure and user experience at sign-in.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Logon UI settings affect information disclosure and user experience at sign-in.' $null
                    }
                }
            }
        }
    }
}
