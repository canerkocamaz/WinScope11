# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 72
    Name        = 'Local Account Hygiene'
    Group       = 'Accounts & Access'
    GroupId     = 13
    Flags       = '[R][A][S]'
    Description = 'Reports local account state and flags long-unused enabled accounts for manual review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 72
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
