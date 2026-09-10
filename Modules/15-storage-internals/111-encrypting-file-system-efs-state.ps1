# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 111
    Name        = 'Encrypting File System (EFS) State'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports EFS service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 111
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
