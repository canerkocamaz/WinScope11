# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 197
    Name        = 'Last Disk Check Results'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][S]'
    Description = 'Reports recent Wininit/CHKDSK result events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 197
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
