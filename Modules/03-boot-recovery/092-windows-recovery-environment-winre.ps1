# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 92
    Name        = 'Windows Recovery Environment (WinRE)'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports WinRE status and recovery configuration using reagentc /info.'
    Adapter     = 'AuditCompat300'
    CompatId    = 92
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
