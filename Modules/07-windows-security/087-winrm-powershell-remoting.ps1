# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 87
    Name        = 'WinRM / PowerShell Remoting'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports WinRM service and listener exposure for remote administration review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 87
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
