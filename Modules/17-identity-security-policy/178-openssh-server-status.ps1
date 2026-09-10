# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 178
    Name        = 'OpenSSH Server Status'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports OpenSSH Server service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 178
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
