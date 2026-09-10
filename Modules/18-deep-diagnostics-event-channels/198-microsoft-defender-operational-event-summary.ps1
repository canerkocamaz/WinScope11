# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 198
    Name        = 'Microsoft Defender Operational Event Summary'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][A][S]'
    Description = 'Reports recent Defender Operational events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 198
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
