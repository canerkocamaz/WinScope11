# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 66
    Name        = 'Environment Variable Integrity'
    Group       = 'Developer & Virtualization'
    GroupId     = 14
    Flags       = '[R][S]'
    Description = 'Finds missing absolute path-like user/machine environment-variable values outside PATH.'
    Adapter     = 'AuditCompat300'
    CompatId    = 66
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
