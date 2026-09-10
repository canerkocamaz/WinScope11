# WinScope 11 native module
[pscustomobject]@{
    Id                = 349
    Name              = 'Windows Update Service Dependency Snapshot'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports state/start mode/account information for key Windows Update services.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($name in @('wuauserv','UsoSvc','WaaSMedicSvc','BITS','TrustedInstaller')) {
            $svc=Get-CimInstance Win32_Service -Filter ("Name='{0}'" -f $name) -ErrorAction SilentlyContinue
            if($null -eq $svc) {
                & $Context.NewFinding 'WindowsUpdateDeep' $name 'NotFound' 'Service not installed or unavailable.' 'Service availability varies by Windows edition/build.' $null
            } else {
                & $Context.NewFinding 'WindowsUpdateDeep' $svc.DisplayName ([string]$svc.State) ("Name={0}; StartMode={1}; StartName={2}; ExitCode={3}" -f $svc.Name,$svc.StartMode,$svc.StartName,$svc.ExitCode) 'Stopped state can be normal for trigger-start servicing services; interpret together with update failures.' $null
            }
        }
    }
}
