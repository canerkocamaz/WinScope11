# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 89
    Name        = 'DISM Component Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Runs DISM CheckHealth only; no RestoreHealth or servicing repair is performed.'
    Adapter     = 'AuditCompat300'
    CompatId    = 89
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
