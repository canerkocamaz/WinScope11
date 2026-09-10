# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 5
    Name        = 'Windows Cache Usage'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Measures important Windows cache locations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 5
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
