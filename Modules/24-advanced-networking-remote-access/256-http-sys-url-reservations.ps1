# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 256
    Name        = 'HTTP.sys URL Reservations'
    Group       = 'Advanced Networking & Remote Access'
    GroupId     = 24
    Flags       = '[R][S]'
    Description = 'Reports HTTP.sys URL ACL reservations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 256
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
