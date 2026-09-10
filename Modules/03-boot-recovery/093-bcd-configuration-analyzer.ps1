# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 93
    Name        = 'BCD Configuration Analyzer'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reads current BCD loader/boot-manager configuration without changing boot data.'
    Adapter     = 'AuditCompat300'
    CompatId    = 93
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
