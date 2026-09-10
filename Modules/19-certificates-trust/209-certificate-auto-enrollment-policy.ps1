# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 209
    Name        = 'Certificate Auto-Enrollment Policy'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Reports machine/user certificate auto-enrollment policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 209
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
