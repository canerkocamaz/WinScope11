# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 169
    Name        = 'Advanced Audit Policy Summary'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Reports Windows advanced audit policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 169
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
