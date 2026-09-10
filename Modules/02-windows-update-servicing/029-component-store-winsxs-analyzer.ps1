# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 29
    Name        = 'Component Store (WinSxS) Analyzer'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Uses DISM to analyze WinSxS and offers supported component cleanup.'
    Adapter     = 'AuditCompat300'
    CompatId    = 29
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
