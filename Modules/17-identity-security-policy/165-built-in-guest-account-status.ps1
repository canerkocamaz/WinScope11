# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 165
    Name        = 'Built-in Guest Account Status'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports the built-in Guest account state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 165
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
