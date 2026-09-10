# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 62
    Name        = 'Hyper-V Virtual Disk Footprint'
    Group       = 'Developer & Virtualization'
    GroupId     = 14
    Flags       = '[R][A][S]'
    Description = 'Reports Hyper-V/common VHD/VHDX files without deleting virtual disks.'
    Adapter     = 'AuditCompat300'
    CompatId    = 62
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
