# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 125
    Name        = 'Installed Windows Capabilities'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Lists installed Windows capabilities.'
    Adapter     = 'AuditCompat300'
    CompatId    = 125
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
