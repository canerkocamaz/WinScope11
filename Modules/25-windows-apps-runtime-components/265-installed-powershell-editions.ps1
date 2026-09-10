# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 265
    Name        = 'Installed PowerShell Editions'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports Windows PowerShell and PowerShell availability.'
    Adapter     = 'AuditCompat300'
    CompatId    = 265
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
