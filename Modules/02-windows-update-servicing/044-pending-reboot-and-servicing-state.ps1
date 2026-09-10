# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 44
    Name        = 'Pending Reboot and Servicing State'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Checks common Windows servicing and reboot-pending indicators.'
    Adapter     = 'AuditCompat300'
    CompatId    = 44
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
