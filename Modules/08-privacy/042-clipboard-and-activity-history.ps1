# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 42
    Name        = 'Clipboard and Activity History'
    Group       = 'Privacy'
    GroupId     = 8
    Flags       = '[R][S]'
    Description = 'Reports clipboard-history and activity-history related configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 42
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
