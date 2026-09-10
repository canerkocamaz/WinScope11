# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 61
    Name        = 'WSL Distribution and VHDX Footprint'
    Group       = 'Developer & Virtualization'
    GroupId     = 14
    Flags       = '[R][S]'
    Description = 'Lists WSL distributions and reports common ext4.vhdx disk footprints.'
    Adapter     = 'AuditCompat300'
    CompatId    = 61
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
