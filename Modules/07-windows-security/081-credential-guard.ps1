# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 81
    Name        = 'Credential Guard'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports Credential Guard configuration and runtime state through DeviceGuard CIM.'
    Adapter     = 'AuditCompat300'
    CompatId    = 81
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
