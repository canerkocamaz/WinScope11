# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 2
    Name        = 'Context Menu Orphans'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Checks context-menu handlers with literal registry paths and validates targets.'
    Adapter     = 'AuditCompat300'
    CompatId    = 2
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
