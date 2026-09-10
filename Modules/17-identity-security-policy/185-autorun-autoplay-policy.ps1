# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 185
    Name        = 'AutoRun / AutoPlay Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports machine/user AutoRun policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 185
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
