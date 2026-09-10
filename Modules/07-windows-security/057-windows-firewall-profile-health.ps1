# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 57
    Name        = 'Windows Firewall Profile Health'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports Domain, Private and Public firewall profile state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 57
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
