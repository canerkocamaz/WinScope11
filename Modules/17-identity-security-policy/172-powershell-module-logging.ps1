# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 172
    Name        = 'PowerShell Module Logging'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports PowerShell module logging policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 172
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
