# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 76
    Name        = 'Network Adapter Hygiene'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Focuses on inactive and recognizable virtual/VPN/WSL/Hyper-V adapters for manual review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 76
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
