# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 221
    Name        = 'Boot Integrity Flags'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports current BCD integrity-related options.'
    Adapter     = 'AuditCompat300'
    CompatId    = 221
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
