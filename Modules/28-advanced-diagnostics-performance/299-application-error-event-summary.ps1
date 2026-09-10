# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 299
    Name        = 'Application Error Event Summary'
    Group       = 'Advanced Diagnostics & Performance'
    GroupId     = 28
    Flags       = '[R][S]'
    Description = 'Reports recent Application log events for triage.'
    Adapter     = 'AuditCompat300'
    CompatId    = 299
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
