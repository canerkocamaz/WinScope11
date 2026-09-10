# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 164
    Name        = 'Account Lockout Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports local account lockout settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 164
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
