# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 235
    Name        = 'Microsoft Edge Policy Snapshot'
    Group       = 'Group Policy & Enterprise Configuration'
    GroupId     = 22
    Flags       = '[R][S]'
    Description = 'Reports selected Microsoft Edge machine policies.'
    Adapter     = 'AuditCompat300'
    CompatId    = 235
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
