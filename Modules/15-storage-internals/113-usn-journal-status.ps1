# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 113
    Name        = 'USN Journal Status'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][A][S]'
    Description = 'Reports the NTFS change journal state on the system volume.'
    Adapter     = 'AuditCompat300'
    CompatId    = 113
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
