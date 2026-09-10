# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 192
    Name        = 'Windows Error Reporting Policy'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][S]'
    Description = 'Reports WER machine/user policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 192
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
