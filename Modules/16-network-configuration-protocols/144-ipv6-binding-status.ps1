# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 144
    Name        = 'IPv6 Binding Status'
    Group       = 'Network Configuration & Protocols'
    GroupId     = 16
    Flags       = '[R][S]'
    Description = 'Reports IPv6 binding state per network adapter.'
    Adapter     = 'AuditCompat300'
    CompatId    = 144
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
