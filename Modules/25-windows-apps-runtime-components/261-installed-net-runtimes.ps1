# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 261
    Name        = 'Installed .NET Runtimes'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports installed modern .NET runtimes.'
    Adapter     = 'AuditCompat300'
    CompatId    = 261
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
