# WinScope 11 native module
[pscustomobject]@{
    Id                = 422
    Name              = 'Services Using Custom Accounts'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports services running under accounts other than built-in service identities.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $builtins=@('LocalSystem','NT AUTHORITY\LocalService','NT AUTHORITY\NetworkService','LocalService','NetworkService')
        try {
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.StartName -and ($builtins -notcontains $_.StartName) -and $_.StartName -notmatch '^NT SERVICE\\'} | Sort-Object StartName,Name)
            foreach($s in $svcs) {
                & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Review' ("Name={0}; Account={1}; State={2}; StartMode={3}; Path={4}" -f $s.Name,$s.StartName,$s.State,$s.StartMode,$s.PathName) 'Service accounts should have documented ownership, least privilege, and appropriate password/service-account management.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Custom service accounts' 'Unavailable' $_.Exception.Message 'CIM service inventory failed.' $null
        }
    }
}
