# WinScope 11 native module
[pscustomobject]@{
    Id                = 320
    Name              = 'Winlogon Notification Packages'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports Winlogon notification package configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Winlogon notification packages';Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';Names=@('Notify','Userinit','Shell')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Unexpected Winlogon extensions can affect persistence and sign-in. Verify vendor ownership before remediation.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Unexpected Winlogon extensions can affect persistence and sign-in. Verify vendor ownership before remediation.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Unexpected Winlogon extensions can affect persistence and sign-in. Verify vendor ownership before remediation.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Unexpected Winlogon extensions can affect persistence and sign-in. Verify vendor ownership before remediation.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Unexpected Winlogon extensions can affect persistence and sign-in. Verify vendor ownership before remediation.' $null
                    }
                }
            }
        }
    }
}
