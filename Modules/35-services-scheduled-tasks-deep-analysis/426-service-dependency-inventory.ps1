# WinScope 11 native module
[pscustomobject]@{
    Id                = 426
    Name              = 'Service Dependency Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports service dependencies for services that declare them.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            foreach($s in @(Get-Service -ErrorAction Stop | Sort-Object Name)) {
                $deps=@($s.ServicesDependedOn | Select-Object -ExpandProperty Name)
                if($deps.Count -gt 0) {
                    & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Info' ("Name={0}; DependsOn={1}" -f $s.Name,($deps -join ',')) 'Dependency relationships help explain service-start failures; report-only.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Service dependencies' 'Unavailable' $_.Exception.Message 'Get-Service dependency inventory failed.' $null
        }
    }
}
