# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 162
    Name        = 'Windows Hello Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports Windows Hello for Business policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 162
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
