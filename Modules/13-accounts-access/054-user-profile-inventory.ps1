# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 54
    Name        = 'User Profile Inventory'
    Group       = 'Accounts & Access'
    GroupId     = 13
    Flags       = '[R][A][S]'
    Description = 'Reports local profiles and flags long-unused, unloaded profiles for manual review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 54
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
