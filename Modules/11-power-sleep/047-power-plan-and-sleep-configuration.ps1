# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 47
    Name        = 'Power Plan and Sleep Configuration'
    Group       = 'Power & Sleep'
    GroupId     = 11
    Flags       = '[R][S]'
    Description = 'Reports the active power plan and available sleep states.'
    Adapter     = 'AuditCompat300'
    CompatId    = 47
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
