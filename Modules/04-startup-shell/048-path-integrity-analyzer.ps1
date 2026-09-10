# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 48
    Name        = 'PATH Integrity Analyzer'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Shows missing and duplicate user/machine PATH entries.'
    Adapter     = 'AuditCompat300'
    CompatId    = 48
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
