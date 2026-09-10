# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 3
    Name        = 'File Explorer Recent Items'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Finds old Recent-item shortcuts and previews them before cleanup.'
    Adapter     = 'AuditCompat300'
    CompatId    = 3
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
