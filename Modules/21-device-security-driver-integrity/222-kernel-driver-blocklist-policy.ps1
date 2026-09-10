# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 222
    Name        = 'Kernel Driver Blocklist Policy'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports vulnerable-driver blocklist policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 222
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
