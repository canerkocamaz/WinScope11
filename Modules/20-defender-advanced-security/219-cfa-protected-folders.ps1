# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 219
    Name        = 'CFA Protected Folders'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports Controlled Folder Access protected folders.'
    Adapter     = 'AuditCompat300'
    CompatId    = 219
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
