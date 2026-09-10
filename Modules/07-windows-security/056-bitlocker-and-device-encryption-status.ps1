# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 56
    Name        = 'BitLocker and Device Encryption Status'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports encryption, protection and lock status without changing BitLocker.'
    Adapter     = 'AuditCompat300'
    CompatId    = 56
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
