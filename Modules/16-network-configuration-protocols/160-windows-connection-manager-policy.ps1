# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 160
    Name        = 'Windows Connection Manager Policy'
    Group       = 'Network Configuration & Protocols'
    GroupId     = 16
    Flags       = '[R][S]'
    Description = 'Reports Windows Connection Manager policy values.'
    Adapter     = 'AuditCompat300'
    CompatId    = 160
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
