# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 77
    Name        = 'Secure Boot Status'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports UEFI Secure Boot status without modifying firmware settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 77
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
