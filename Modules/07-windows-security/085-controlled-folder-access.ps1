# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 85
    Name        = 'Controlled Folder Access'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports Defender Controlled Folder Access mode and configured lists.'
    Adapter     = 'AuditCompat300'
    CompatId    = 85
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
