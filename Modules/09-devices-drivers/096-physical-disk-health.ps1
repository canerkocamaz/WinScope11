# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 96
    Name        = 'Physical Disk Health'
    Group       = 'Devices & Drivers'
    GroupId     = 9
    Flags       = '[R][A][S]'
    Description = 'Reports physical-disk health and available storage reliability counters.'
    Adapter     = 'AuditCompat300'
    CompatId    = 96
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
