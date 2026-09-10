# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 43
    Name        = 'Windows Update Download Cache'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Measures SoftwareDistribution download-cache usage without manual deletion.'
    Adapter     = 'AuditCompat300'
    CompatId    = 43
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
