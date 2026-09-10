# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 255
    Name        = 'WPAD and Proxy Auto-Discovery Policy'
    Group       = 'Advanced Networking & Remote Access'
    GroupId     = 24
    Flags       = '[R][S]'
    Description = 'Reports WPAD/PAC/proxy auto-discovery configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 255
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
