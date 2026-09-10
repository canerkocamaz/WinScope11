# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 40
    Name        = 'Print Queue and Spooler'
    Group       = 'Devices & Drivers'
    GroupId     = 9
    Flags       = '[R][A][S]'
    Description = 'Reports printers, Print Spooler state and queued spool-file usage.'
    Adapter     = 'AuditCompat300'
    CompatId    = 40
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
