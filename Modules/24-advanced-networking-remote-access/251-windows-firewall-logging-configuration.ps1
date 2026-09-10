# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 251
    Name        = 'Windows Firewall Logging Configuration'
    Group       = 'Advanced Networking & Remote Access'
    GroupId     = 24
    Flags       = '[R][S]'
    Description = 'Reports firewall log paths and logging settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 251
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
