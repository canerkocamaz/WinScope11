# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 206
    Name        = 'Code Signing Certificate Inventory'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Reports code-signing certificates without exporting private keys.'
    Adapter     = 'AuditCompat300'
    CompatId    = 206
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
