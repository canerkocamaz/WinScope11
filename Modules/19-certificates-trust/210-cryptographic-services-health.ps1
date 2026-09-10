# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 210
    Name        = 'Cryptographic Services Health'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Reports Cryptographic Services state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 210
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
