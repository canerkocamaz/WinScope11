# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 220
    Name        = 'Defender Quarantine Retention'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports quarantine and remediation scheduling settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 220
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
