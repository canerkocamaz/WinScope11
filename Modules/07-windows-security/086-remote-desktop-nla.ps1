# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 86
    Name        = 'Remote Desktop / NLA'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports RDP enablement and Network Level Authentication state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 86
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
