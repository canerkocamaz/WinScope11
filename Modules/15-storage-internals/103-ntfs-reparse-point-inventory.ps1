# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 103
    Name        = 'NTFS Reparse Point Inventory'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Inventories junctions, symbolic links and other reparse points in scoped paths.'
    Adapter     = 'AuditCompat300'
    CompatId    = 103
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
