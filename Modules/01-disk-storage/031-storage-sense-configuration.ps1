# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 31
    Name        = 'Storage Sense Configuration'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Reports the current-user Storage Sense configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 31
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
