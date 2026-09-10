# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 208
    Name        = 'Enterprise Trust Store'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Reports enterprise trust certificates when present.'
    Adapter     = 'AuditCompat300'
    CompatId    = 208
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
