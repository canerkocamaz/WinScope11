# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 153
    Name        = 'SMB Client Configuration'
    Group       = 'Network Configuration & Protocols'
    GroupId     = 16
    Flags       = '[R][A][S]'
    Description = 'Reports SMB client security and caching settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 153
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
