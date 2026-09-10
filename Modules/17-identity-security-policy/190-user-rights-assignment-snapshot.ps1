# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 190
    Name        = 'User Rights Assignment Snapshot'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Exports and reports local user-right assignments without changing them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 190
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
