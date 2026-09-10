# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 170
    Name        = 'PowerShell Script Block Logging'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports Script Block Logging policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 170
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
