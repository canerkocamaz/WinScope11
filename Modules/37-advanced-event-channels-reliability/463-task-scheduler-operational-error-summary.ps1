# WinScope 11 native module
[pscustomobject]@{
    Id                = 463
    Name              = 'Task Scheduler Operational Error Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-TaskScheduler/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'TaskScheduler' 'Task Scheduler Operational Error Summary' 'Microsoft-Windows-TaskScheduler/Operational' 30 80 '' 'Task Scheduler Operational errors help explain failed or blocked scheduled tasks.' -ErrorsOnly
    }
}
