# WinScope 11 native module
[pscustomobject]@{
    Id                = 424
    Name              = 'Service Failure Action Configuration'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports whether services have configured FailureActions registry data.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root='HKLM:\SYSTEM\CurrentControlSet\Services'
        try {
            foreach($svc in @(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.StartMode -eq 'Auto'} | Sort-Object Name)) {
                $path=Join-Path $root $svc.Name
                $p=Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
                $has=$null -ne $p -and ($p.PSObject.Properties.Name -contains 'FailureActions')
                & $Context.NewFinding 'ServiceDeep' $svc.DisplayName $(if($has){'Configured'}else{'None'}) ("Name={0}; Automatic={1}; FailureActionsPresent={2}" -f $svc.Name,$svc.StartMode,$has) 'Failure actions can improve resilience but must be appropriate for the service and failure mode.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Service failure actions' 'Unavailable' $_.Exception.Message 'Unable to enumerate service configuration.' $null
        }
    }
}
