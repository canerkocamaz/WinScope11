# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 90
    Name        = 'SFC VerifyOnly'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Runs System File Checker in verify-only mode and performs no automatic repair.'
    Adapter     = 'AuditCompat300'
    CompatId    = 90
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
