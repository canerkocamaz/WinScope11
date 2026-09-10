# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 296
    Name        = 'Top Memory Processes Snapshot'
    Group       = 'Advanced Diagnostics & Performance'
    GroupId     = 28
    Flags       = '[R][S]'
    Description = 'Reports top processes by working set.'
    Adapter     = 'AuditCompat300'
    CompatId    = 296
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
