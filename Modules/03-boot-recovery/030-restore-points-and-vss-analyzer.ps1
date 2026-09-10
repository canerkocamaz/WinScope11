# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 30
    Name        = 'Restore Points and VSS Analyzer'
    Group       = 'Boot & Recovery'
    GroupId     = 3
    Flags       = '[R][A][S]'
    Description = 'Reports restore points and VSS shadow-storage usage.'
    Adapter     = 'AuditCompat300'
    CompatId    = 30
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
