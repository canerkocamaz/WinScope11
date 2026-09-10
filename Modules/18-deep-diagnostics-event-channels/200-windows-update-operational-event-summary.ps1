# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 200
    Name        = 'Windows Update Operational Event Summary'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][A][S]'
    Description = 'Reports recent Windows Update operational events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 200
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
