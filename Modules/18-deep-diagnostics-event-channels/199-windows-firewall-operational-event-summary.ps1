# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 199
    Name        = 'Windows Firewall Operational Event Summary'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][A][S]'
    Description = 'Reports recent Windows Firewall operational events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 199
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
