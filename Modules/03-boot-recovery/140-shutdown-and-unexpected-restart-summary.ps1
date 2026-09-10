# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 140
    Name        = 'Shutdown and Unexpected Restart Summary'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][S]'
    Description = 'Summarizes shutdown, restart and unexpected shutdown events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 140
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
