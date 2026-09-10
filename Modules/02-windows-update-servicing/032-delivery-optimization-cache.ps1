# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 32
    Name        = 'Delivery Optimization Cache'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Measures Windows Delivery Optimization cache locations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 32
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
