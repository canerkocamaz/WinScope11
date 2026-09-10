# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 36
    Name        = 'Microsoft Store Cache'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Measures Microsoft Store cache locations without deleting package data.'
    Adapter     = 'AuditCompat300'
    CompatId    = 36
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
