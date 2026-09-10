# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 297
    Name        = 'Top CPU Processes Snapshot'
    Group       = 'Advanced Diagnostics & Performance'
    GroupId     = 28
    Flags       = '[R][S]'
    Description = 'Reports top processes by cumulative CPU time.'
    Adapter     = 'AuditCompat300'
    CompatId    = 297
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
