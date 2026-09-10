# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 288
    Name        = 'Windows Copilot Policy'
    Group       = 'User Experience & Privacy'
    GroupId     = 27
    Flags       = '[R][S]'
    Description = 'Reports Windows Copilot policy values when present.'
    Adapter     = 'AuditCompat300'
    CompatId    = 288
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
