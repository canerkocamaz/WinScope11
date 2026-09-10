# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 79
    Name        = 'Virtualization-Based Security (VBS)'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports Device Guard VBS state and configured/running security services.'
    Adapter     = 'AuditCompat300'
    CompatId    = 79
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
