# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 131
    Name        = 'Recovery Partition Inventory'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports Windows recovery partitions.'
    Adapter     = 'AuditCompat300'
    CompatId    = 131
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
