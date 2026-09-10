# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 52
    Name        = 'PowerShell Module Footprint'
    Group       = 'Developer & Virtualization'
    GroupId     = 14
    Flags       = '[R][S]'
    Description = 'Shows the largest PowerShell module folders and multiple-version footprints.'
    Adapter     = 'AuditCompat300'
    CompatId    = 52
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
