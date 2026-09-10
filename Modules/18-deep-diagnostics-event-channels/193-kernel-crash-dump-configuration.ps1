# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 193
    Name        = 'Kernel Crash Dump Configuration'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][S]'
    Description = 'Reports kernel crash dump settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 193
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
