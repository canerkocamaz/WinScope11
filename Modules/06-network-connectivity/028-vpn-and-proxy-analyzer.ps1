# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 28
    Name        = 'VPN and Proxy Analyzer'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Reports saved VPN connections plus WinINET and WinHTTP proxy configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 28
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
