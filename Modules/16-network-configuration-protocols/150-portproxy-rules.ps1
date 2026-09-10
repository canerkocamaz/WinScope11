# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 150
    Name        = 'PortProxy Rules'
    Group       = 'Network Configuration & Protocols'
    GroupId     = 16
    Flags       = '[R][A][S]'
    Description = 'Lists netsh interface portproxy rules.'
    Adapter     = 'AuditCompat300'
    CompatId    = 150
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
