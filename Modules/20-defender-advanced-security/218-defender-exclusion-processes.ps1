# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 218
    Name        = 'Defender Exclusion Processes'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports process exclusions.'
    Adapter     = 'AuditCompat300'
    CompatId    = 218
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
