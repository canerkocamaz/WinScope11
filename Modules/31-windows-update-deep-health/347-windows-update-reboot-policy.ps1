# WinScope 11 native module
[pscustomobject]@{
    Id                = 347
    Name              = 'Windows Update Reboot Policy'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports selected Group Policy values controlling automatic update reboot behavior.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Windows Update AU policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU';Names=@('NoAutoRebootWithLoggedOnUsers','AlwaysAutoRebootAtScheduledTime','AlwaysAutoRebootAtScheduledTimeMinutes','RebootWarningTimeoutEnabled','RebootWarningTimeout')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Reboot policy should be aligned with maintenance windows and endpoint-management policy.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Reboot policy should be aligned with maintenance windows and endpoint-management policy.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'Info' ($pairs -join '; ') 'Reboot policy should be aligned with maintenance windows and endpoint-management policy.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'WindowsUpdateDeep' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Reboot policy should be aligned with maintenance windows and endpoint-management policy.' $null
                    } else {
                        & $Context.NewFinding 'WindowsUpdateDeep' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Reboot policy should be aligned with maintenance windows and endpoint-management policy.' $null
                    }
                }
            }
        }
    }
}
