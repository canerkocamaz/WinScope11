# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 175
    Name        = 'Windows Sandbox Feature'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports Windows Sandbox optional feature state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 175
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
