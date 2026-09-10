# WinScope 11 native module
[pscustomobject]@{
    Id                = 421
    Name              = 'Services Running as LocalSystem'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports Windows services configured to run as LocalSystem.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.StartName -eq 'LocalSystem'} | Sort-Object Name)
            foreach($s in $svcs) {
                & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Info' ("Name={0}; State={1}; StartMode={2}; Path={3}" -f $s.Name,$s.State,$s.StartMode,$s.PathName) 'LocalSystem is highly privileged but normal for many Windows services; focus on unexpected third-party services.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'LocalSystem services' 'Unavailable' $_.Exception.Message 'CIM service inventory failed.' $null
        }
    }
}
