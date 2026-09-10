# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 229
    Name        = 'Kernel PnP Error Events'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports recent Kernel-PnP errors.'
    Adapter     = 'AuditCompat300'
    CompatId    = 229
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
