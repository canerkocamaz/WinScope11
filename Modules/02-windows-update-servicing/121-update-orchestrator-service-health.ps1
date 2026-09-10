# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 121
    Name        = 'Update Orchestrator Service Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports Update Orchestrator service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 121
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
