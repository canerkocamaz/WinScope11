# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 137
    Name        = 'Task Manager StartupApproved Inventory'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports Task Manager startup approval registry state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 137
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
