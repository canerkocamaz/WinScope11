# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 260
    Name        = 'Terminal Session Inventory'
    Group       = 'Advanced Networking & Remote Access'
    GroupId     = 24
    Flags       = '[R][S]'
    Description = 'Reports current terminal sessions without disconnecting users.'
    Adapter     = 'AuditCompat300'
    CompatId    = 260
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
