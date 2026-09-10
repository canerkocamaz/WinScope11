# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 127
    Name        = 'Installed Update Inventory'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Lists installed hotfix/update inventory.'
    Adapter     = 'AuditCompat300'
    CompatId    = 127
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
