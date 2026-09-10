# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 58
    Name        = 'Orphaned Firewall Application Rules'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Finds firewall application filters that reference missing executable paths.'
    Adapter     = 'AuditCompat300'
    CompatId    = 58
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
