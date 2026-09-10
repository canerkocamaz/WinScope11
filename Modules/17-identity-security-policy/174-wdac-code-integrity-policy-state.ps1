# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 174
    Name        = 'WDAC / Code Integrity Policy State'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Reports Device Guard / Code Integrity enforcement state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 174
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
