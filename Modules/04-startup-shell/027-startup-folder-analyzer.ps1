# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 27
    Name        = 'Startup Folder Analyzer'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Checks current-user and common Startup folders for shortcut targets.'
    Adapter     = 'AuditCompat300'
    CompatId    = 27
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
