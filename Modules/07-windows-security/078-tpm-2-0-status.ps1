# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 78
    Name        = 'TPM 2.0 Status'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports TPM presence/readiness without initializing or clearing the TPM.'
    Adapter     = 'AuditCompat300'
    CompatId    = 78
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
