# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 15
    Name        = 'Invalid CLSID / COM Registrations'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Finds COM registrations whose InprocServer32 target appears missing.'
    Adapter     = 'AuditCompat300'
    CompatId    = 15
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
