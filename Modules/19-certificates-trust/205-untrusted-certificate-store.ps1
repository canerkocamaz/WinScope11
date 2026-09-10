# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 205
    Name        = 'Untrusted Certificate Store'
    Group       = 'Certificates & Trust'
    GroupId     = 19
    Flags       = '[R][S]'
    Description = 'Reports certificates explicitly placed in the Disallowed store.'
    Adapter     = 'AuditCompat300'
    CompatId    = 205
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
