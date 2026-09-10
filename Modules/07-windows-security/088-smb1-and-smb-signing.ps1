# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 88
    Name        = 'SMB1 and SMB Signing'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports SMB1 plus SMB client/server signing and insecure guest settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 88
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
