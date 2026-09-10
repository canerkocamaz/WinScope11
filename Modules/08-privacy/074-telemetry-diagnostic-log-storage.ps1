# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 74
    Name        = 'Telemetry & Diagnostic Log Storage'
    Group       = 'Privacy'
    GroupId     = 8
    Flags       = '[R][A][S]'
    Description = 'Measures common Windows diagnostic, WMI AutoLogger and ETL storage locations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 74
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
