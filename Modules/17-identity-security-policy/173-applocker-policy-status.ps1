# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 173
    Name        = 'AppLocker Policy Status'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Reports effective AppLocker rule collection state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 173
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
