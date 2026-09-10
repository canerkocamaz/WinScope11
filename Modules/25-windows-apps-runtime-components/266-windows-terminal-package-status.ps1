# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 266
    Name        = 'Windows Terminal Package Status'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports Windows Terminal Appx package state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 266
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
