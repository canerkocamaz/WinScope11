# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 100
    Name        = 'Power Requests'
    Group       = 'Power & Sleep'
    GroupId     = 11
    Flags       = '[R][A][S]'
    Description = 'Reports active process/driver requests that can prevent sleep or display-off.'
    Adapter     = 'AuditCompat300'
    CompatId    = 100
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
