# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 204
    Name        = 'Expired Machine Certificates'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Finds expired certificates across machine stores.'
    Adapter     = 'AuditCompat300'
    CompatId    = 204
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
