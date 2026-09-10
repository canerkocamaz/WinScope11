# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 289
    Name        = 'Windows AI / Recall Policy Snapshot'
    Group       = 'User Experience & Privacy'
    GroupId     = 27
    Flags       = '[R][S]'
    Description = 'Reports Windows AI/Recall-related policy values when present.'
    Adapter     = 'AuditCompat300'
    CompatId    = 289
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
