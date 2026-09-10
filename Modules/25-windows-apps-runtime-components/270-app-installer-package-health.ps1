# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 270
    Name        = 'App Installer Package Health'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports Microsoft Desktop App Installer package state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 270
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
