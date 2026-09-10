# WinScope 11 native module
[pscustomobject]@{
    Id                = 439
    Name              = 'Scheduled Task Principal Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports non-SYSTEM scheduled-task principals and run levels.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $seen=@{}
            foreach($t in @(Get-ScheduledTask -ErrorAction Stop)) {
                $u=[string]$t.Principal.UserId
                if([string]::IsNullOrWhiteSpace($u) -or $u -match '^(SYSTEM|S-1-5-18)$'){continue}
                $key="{0}|{1}|{2}" -f $u,$t.Principal.LogonType,$t.Principal.RunLevel
                if($seen.ContainsKey($key)){continue}
                $seen[$key]=$true
                & $Context.NewFinding 'TaskDeep' $u 'Info' ("LogonType={0}; RunLevel={1}" -f $t.Principal.LogonType,$t.Principal.RunLevel) 'Task principals should map to current, intended service/user identities.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Task principals' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
