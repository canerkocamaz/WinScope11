# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 167
    Name        = 'AutoLogon Configuration'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Checks for Windows automatic logon configuration without reading passwords.'
    Adapter     = 'AuditCompat300'
    CompatId    = 167
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
