# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 181
    Name        = 'NTLM Restriction Policy'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][S]'
    Description = 'Reports NTLM traffic restriction/audit policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 181
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
