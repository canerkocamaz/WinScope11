# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 276
    Name        = 'Windows Installer Service Health'
    Group       = 'System Services & Management'
    GroupId     = 26
    Flags       = '[R][S]'
    Description = 'Reports Windows Installer service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 276
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
