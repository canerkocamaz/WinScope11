# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 136
    Name        = 'Boot Logging State'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports current BCD boot logging configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 136
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
