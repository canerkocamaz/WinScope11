# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 22
    Name        = 'Downloads Folder Cleanup'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Finds old Downloads files, shows them, then asks before deletion.'
    Adapter     = 'AuditCompat300'
    CompatId    = 22
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
