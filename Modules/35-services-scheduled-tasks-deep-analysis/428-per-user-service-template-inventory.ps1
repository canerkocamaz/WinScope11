# WinScope 11 native module
[pscustomobject]@{
    Id                = 428
    Name              = 'Per-User Service Template Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports service templates commonly instantiated per user session.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.Name -match '_[0-9a-fA-F]{5,}$'} | Sort-Object Name)
            foreach($s in $svcs) {
                & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Info' ("Name={0}; State={1}; StartMode={2}; Account={3}" -f $s.Name,$s.State,$s.StartMode,$s.StartName) 'Per-user services are normal on Windows 10/11; investigate only unexpected names or behavior.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Per-user services' 'Unavailable' $_.Exception.Message 'CIM service inventory failed.' $null
        }
    }
}
