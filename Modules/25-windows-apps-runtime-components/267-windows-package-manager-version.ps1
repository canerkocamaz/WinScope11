# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 267
    Name        = 'Windows Package Manager Version'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports winget availability/version.'
    Adapter     = 'AuditCompat300'
    CompatId    = 267
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
