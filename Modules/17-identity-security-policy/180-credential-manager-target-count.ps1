# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 180
    Name        = 'Credential Manager Target Count'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Counts stored credential targets without exposing target names or secrets.'
    Adapter     = 'AuditCompat300'
    CompatId    = 180
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
