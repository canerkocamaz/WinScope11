# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 135
    Name        = 'SafeBoot Configuration'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports SafeBoot-related BCD state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 135
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
