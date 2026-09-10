# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 212
    Name        = 'Defender PUA Protection'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports potentially unwanted application protection.'
    Adapter     = 'AuditCompat300'
    CompatId    = 212
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
