# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 171
    Name        = 'PowerShell Transcription Logging'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports PowerShell transcription policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 171
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
