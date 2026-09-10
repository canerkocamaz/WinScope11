# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 71
    Name        = 'Provisioned App Inventory'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Lists Appx packages provisioned for future/new user profiles.'
    Adapter     = 'AuditCompat300'
    CompatId    = 71
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
