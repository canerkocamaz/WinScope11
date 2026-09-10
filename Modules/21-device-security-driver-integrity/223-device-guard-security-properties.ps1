# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 223
    Name        = 'Device Guard Security Properties'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports Win32_DeviceGuard security properties.'
    Adapter     = 'AuditCompat300'
    CompatId    = 223
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
