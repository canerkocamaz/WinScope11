# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 53
    Name        = 'Windows Installer Cache Analyzer'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][A][S]'
    Description = 'Measures C:\Windows\Installer and shows the largest MSI/MSP files; never auto-deletes them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 53
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
