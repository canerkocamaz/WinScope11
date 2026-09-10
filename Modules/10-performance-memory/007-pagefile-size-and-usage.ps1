# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 7
    Name        = 'Pagefile Size and Usage'
    Group       = 'Performance & Memory'
    GroupId     = 10
    Flags       = '[R][S]'
    Description = 'Reports pagefile allocation, current use and peak use.'
    Adapter     = 'AuditCompat300'
    CompatId    = 7
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
