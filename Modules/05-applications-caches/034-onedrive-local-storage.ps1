# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 34
    Name        = 'OneDrive Local Storage'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Measures common OneDrive local sync folders without deleting synchronized files.'
    Adapter     = 'AuditCompat300'
    CompatId    = 34
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
