# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 196
    Name        = 'Reliability Critical Event Summary'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][S]'
    Description = 'Reports recent Windows reliability records.'
    Adapter     = 'AuditCompat300'
    CompatId    = 196
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
