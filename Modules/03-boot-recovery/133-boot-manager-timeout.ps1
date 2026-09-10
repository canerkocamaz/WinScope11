# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 133
    Name        = 'Boot Manager Timeout'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports boot manager BCD settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 133
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
