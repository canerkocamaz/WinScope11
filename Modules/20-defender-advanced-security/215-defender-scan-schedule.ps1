# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 215
    Name        = 'Defender Scan Schedule'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports scheduled scan policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 215
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
