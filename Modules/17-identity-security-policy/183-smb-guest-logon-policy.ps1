# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 183
    Name        = 'SMB Guest Logon Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports insecure SMB guest logon policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 183
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
