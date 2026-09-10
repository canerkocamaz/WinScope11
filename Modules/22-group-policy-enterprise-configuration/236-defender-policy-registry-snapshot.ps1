# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 236
    Name        = 'Defender Policy Registry Snapshot'
    Group       = 'Group Policy & Enterprise Configuration'
    GroupId     = 22
    Flags       = '[R][S]'
    Description = 'Reports selected Defender policy registry values.'
    Adapter     = 'AuditCompat300'
    CompatId    = 236
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
