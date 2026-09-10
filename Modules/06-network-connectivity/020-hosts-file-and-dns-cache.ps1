# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 20
    Name        = 'Hosts File and DNS Cache'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Reviews hosts entries and shows DNS cache records before optional flush.'
    Adapter     = 'AuditCompat300'
    CompatId    = 20
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
