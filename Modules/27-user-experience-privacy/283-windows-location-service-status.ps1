# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 283
    Name        = 'Windows Location Service Status'
    Group       = 'User Experience & Privacy'
    GroupId     = 27
    Flags       = '[R][S]'
    Description = 'Reports Windows Geolocation Service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 283
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
