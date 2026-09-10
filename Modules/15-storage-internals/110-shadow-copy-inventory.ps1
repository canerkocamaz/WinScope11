# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 110
    Name        = 'Shadow Copy Inventory'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][A][S]'
    Description = 'Lists current VSS shadow copies without deleting them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 110
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
