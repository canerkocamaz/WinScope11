# WinScope 11 native module
[pscustomobject]@{
    Id                = 425
    Name              = 'Service Trigger Configuration Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports services with TriggerInfo registry configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root='HKLM:\SYSTEM\CurrentControlSet\Services'
        try {
            $keys=@(Get-ChildItem -LiteralPath $root -ErrorAction Stop)
            foreach($k in $keys) {
                $tp=Join-Path $k.PSPath 'TriggerInfo'
                if(Test-Path -LiteralPath $tp) {
                    & $Context.NewFinding 'ServiceDeep' $k.PSChildName 'TriggerConfigured' ("Registry={0}" -f $tp) 'Trigger-start services can legitimately remain stopped until a trigger condition occurs.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Service TriggerInfo' 'Unavailable' $_.Exception.Message 'Unable to enumerate service TriggerInfo.' $null
        }
    }
}
