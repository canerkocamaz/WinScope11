# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 25
    Name        = 'Windows Error Reporting'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][A][S]'
    Description = 'Measures old WER reports and previews removable report files.'
    Adapter     = 'AuditCompat300'
    CompatId    = 25
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
