# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 12
    Name        = 'Defender Exclusion Orphans'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Finds Defender exclusion paths that no longer exist and previews removal.'
    Adapter     = 'AuditCompat300'
    CompatId    = 12
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
