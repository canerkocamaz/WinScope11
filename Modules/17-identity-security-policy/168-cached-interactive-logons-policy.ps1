# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 168
    Name        = 'Cached Interactive Logons Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports cached domain-logon count policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 168
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
