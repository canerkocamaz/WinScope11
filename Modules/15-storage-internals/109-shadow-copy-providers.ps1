# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 109
    Name        = 'Shadow Copy Providers'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][A][S]'
    Description = 'Lists registered VSS providers.'
    Adapter     = 'AuditCompat300'
    CompatId    = 109
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
