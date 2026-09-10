# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 226
    Name        = 'Driver Verifier Configuration'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports Driver Verifier settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 226
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
