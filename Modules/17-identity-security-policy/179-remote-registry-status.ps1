# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 179
    Name        = 'Remote Registry Status'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports Remote Registry service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 179
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
