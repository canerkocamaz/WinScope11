# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 298
    Name        = 'System Error Event Summary'
    Group       = 'Advanced Diagnostics & Performance'
    GroupId     = 28
    Flags       = '[R][S]'
    Description = 'Reports recent System log events for triage.'
    Adapter     = 'AuditCompat300'
    CompatId    = 298
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
