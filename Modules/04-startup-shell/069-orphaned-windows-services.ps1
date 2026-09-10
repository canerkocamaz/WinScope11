# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 69
    Name        = 'Orphaned Windows Services'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][A][S]'
    Description = 'Finds user-mode Windows services whose executable target appears missing.'
    Adapter     = 'AuditCompat300'
    CompatId    = 69
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
