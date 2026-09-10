# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 4
    Name        = 'Temporary Files'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Finds old temp files and previews every deletion candidate.'
    Adapter     = 'AuditCompat300'
    CompatId    = 4
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
