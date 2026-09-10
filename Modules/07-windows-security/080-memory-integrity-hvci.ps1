# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 80
    Name        = 'Memory Integrity / HVCI'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports HVCI/Memory Integrity configuration and runtime state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 80
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
