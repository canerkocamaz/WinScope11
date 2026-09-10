# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 163
    Name        = 'Local Password Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports local password policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 163
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
