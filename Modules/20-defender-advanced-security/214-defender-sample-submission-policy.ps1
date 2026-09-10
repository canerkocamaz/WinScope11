# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 214
    Name        = 'Defender Sample Submission Policy'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports Defender sample-submission consent configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 214
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
