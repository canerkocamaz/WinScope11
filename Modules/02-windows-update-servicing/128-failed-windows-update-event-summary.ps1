# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 128
    Name        = 'Failed Windows Update Event Summary'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Summarizes recent Windows Update client events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 128
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
