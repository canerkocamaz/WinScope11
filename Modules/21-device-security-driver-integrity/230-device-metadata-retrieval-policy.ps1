# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 230
    Name        = 'Device Metadata Retrieval Policy'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports device metadata network-retrieval policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 230
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
