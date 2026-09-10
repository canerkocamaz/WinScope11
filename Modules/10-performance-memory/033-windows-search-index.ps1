# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 33
    Name        = 'Windows Search Index'
    Group       = 'Performance & Memory'
    GroupId     = 10
    Flags       = '[R][S]'
    Description = 'Reports Windows Search database size and service status.'
    Adapter     = 'AuditCompat300'
    CompatId    = 33
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
