# WinScope 11 native module
[pscustomobject]@{
    Id                = 436
    Name              = 'Scheduled Task Missing Executable Actions'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports Exec task actions whose local executable target cannot be found.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $found=0
            foreach($t in @(Get-ScheduledTask -ErrorAction Stop)) {
                foreach($a in @($t.Actions)) {
                    $exe=[Environment]::ExpandEnvironmentVariables([string]$a.Execute).Trim('"')
                    if([string]::IsNullOrWhiteSpace($exe)){continue}
                    if($exe -notmatch '[\\/:]'){continue}
                    if($exe -match '^\\\\'){continue}
                    if(-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
                        $found++
                        & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Suspicious' ("Missing executable={0}; Arguments={1}" -f $exe,$a.Arguments) 'Confirm that the task is stale before disabling/removing it; environment/path indirection can produce false positives.' $null
                    }
                }
            }
            if($found -eq 0) {
                & $Context.NewFinding 'TaskDeep' 'Missing task executables' 'Healthy' 'No obvious missing absolute Exec targets were found.' 'No action required based on this check.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Missing task executables' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
