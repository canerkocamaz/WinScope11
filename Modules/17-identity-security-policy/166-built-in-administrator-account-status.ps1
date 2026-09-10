# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 166
    Name        = 'Built-in Administrator Account Status'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports the built-in Administrator account state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 166
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
