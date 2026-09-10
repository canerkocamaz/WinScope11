# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 95
    Name        = 'TRIM / Delete Notification Status'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][A][S]'
    Description = 'Reports NTFS/ReFS delete-notification state used by modern storage stacks.'
    Adapter     = 'AuditCompat300'
    CompatId    = 95
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
