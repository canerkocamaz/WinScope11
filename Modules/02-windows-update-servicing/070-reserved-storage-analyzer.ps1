# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 70
    Name        = 'Reserved Storage Analyzer'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Reports Windows Reserved Storage state through DISM without changing it.'
    Adapter     = 'AuditCompat300'
    CompatId    = 70
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
