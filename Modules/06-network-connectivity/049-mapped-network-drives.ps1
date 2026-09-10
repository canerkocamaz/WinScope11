# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 49
    Name        = 'Mapped Network Drives'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Reports current SMB/file-system drive mappings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 49
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
