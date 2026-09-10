# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 154
    Name        = 'SMB Server Configuration'
    Group       = 'Network Configuration & Protocols'
    GroupId     = 16
    Flags       = '[R][A][S]'
    Description = 'Reports SMB server protocol and signing settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 154
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
