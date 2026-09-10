# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 161
    Name        = 'User Account Control (UAC) Configuration'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports important UAC security values.'
    Adapter     = 'AuditCompat300'
    CompatId    = 161
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
