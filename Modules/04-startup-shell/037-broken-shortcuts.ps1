# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 37
    Name        = 'Broken Shortcuts'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Checks Desktop and Start Menu .lnk files for missing targets.'
    Adapter     = 'AuditCompat300'
    CompatId    = 37
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
