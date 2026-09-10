# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 233
    Name        = 'Windows Update for Business Policy'
    Group       = 'Group Policy & Enterprise Configuration'
    GroupId     = 22
    Flags       = '[R][S]'
    Description = 'Reports WUfB deferral/pause policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 233
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
