# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 189
    Name        = 'Local Privileged Group Membership Review'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Reviews membership of important local privileged groups.'
    Adapter     = 'AuditCompat300'
    CompatId    = 189
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
