# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 122
    Name        = 'Windows Modules Installer Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports TrustedInstaller service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 122
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
