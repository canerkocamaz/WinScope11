# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 99
    Name        = 'Modern Standby Support'
    Group       = 'Power & Sleep'
    GroupId     = 11
    Flags       = '[R][S]'
    Description = 'Reports S0 Low Power Idle / Modern Standby support from powercfg.'
    Adapter     = 'AuditCompat300'
    CompatId    = 99
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
