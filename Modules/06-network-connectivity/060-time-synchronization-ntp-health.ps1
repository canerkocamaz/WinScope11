# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 60
    Name        = 'Time Synchronization / NTP Health'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Reports Windows Time service, time source and w32tm synchronization status.'
    Adapter     = 'AuditCompat300'
    CompatId    = 60
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
