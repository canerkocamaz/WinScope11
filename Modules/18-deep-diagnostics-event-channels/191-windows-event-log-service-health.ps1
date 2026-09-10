# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 191
    Name        = 'Windows Event Log Service Health'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][S]'
    Description = 'Reports Windows Event Log service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 191
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
