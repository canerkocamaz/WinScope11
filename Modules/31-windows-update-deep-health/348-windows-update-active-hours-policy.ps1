# WinScope 11 native module
[pscustomobject]@{
    Id                = 348
    Name              = 'Windows Update Active Hours Policy'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports configured Windows Update active-hours policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='Windows Update active hours';Path='HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings';Names=@('ActiveHoursStart','ActiveHoursEnd','SmartActiveHoursState')},
            @{Item='Policy active hours';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';Names=@('SetActiveHours','ActiveHoursStart','ActiveHoursEnd','ActiveHoursMaxRange')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Active-hours settings influence update restart timing and user disruption.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Active-hours settings influence update restart timing and user disruption.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'WindowsUpdateDeep' $check.Item 'Info' ($pairs -join '; ') 'Active-hours settings influence update restart timing and user disruption.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'WindowsUpdateDeep' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Active-hours settings influence update restart timing and user disruption.' $null
                    } else {
                        & $Context.NewFinding 'WindowsUpdateDeep' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Active-hours settings influence update restart timing and user disruption.' $null
                    }
                }
            }
        }
    }
}
