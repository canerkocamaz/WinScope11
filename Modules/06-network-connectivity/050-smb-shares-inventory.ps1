# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 50
    Name        = 'SMB Shares Inventory'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][A][S]'
    Description = 'Reports local SMB shares and highlights non-system shares for review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 50
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
