# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 18
    Name        = 'Previous Windows Installation'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Reports Windows.old and its estimated disk usage.'
    Adapter     = 'AuditCompat300'
    CompatId    = 18
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
