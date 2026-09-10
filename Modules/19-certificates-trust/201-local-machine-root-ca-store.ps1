# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 201
    Name        = 'Local Machine Root CA Store'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Trusted root CA inventory and expiration visibility.'
    Adapter     = 'AuditCompat300'
    CompatId    = 201
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
