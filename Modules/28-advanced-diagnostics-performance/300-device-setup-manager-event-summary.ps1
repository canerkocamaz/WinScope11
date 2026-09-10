# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 300
    Name        = 'Device Setup Manager Event Summary'
    Group       = 'Advanced Diagnostics & Performance'
    GroupId     = 28
    Flags       = '[R][S]'
    Description = 'Reports recent Device Setup Manager events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 300
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
