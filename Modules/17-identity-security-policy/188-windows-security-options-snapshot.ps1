# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 188
    Name        = 'Windows Security Options Snapshot'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports a focused snapshot of local security options.'
    Adapter     = 'AuditCompat300'
    CompatId    = 188
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
