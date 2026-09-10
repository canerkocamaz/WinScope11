# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 10
    Name        = 'Saved Wi-Fi Profiles'
    Group       = 'Network & Connectivity'
    GroupId     = 6
    Flags       = '[R][S]'
    Description = 'Lists saved Wi-Fi profiles and allows one-at-a-time deletion after preview.'
    Adapter     = 'AuditCompat300'
    CompatId    = 10
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
