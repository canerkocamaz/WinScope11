# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 84
    Name        = 'Attack Surface Reduction (ASR) Rules'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Lists Defender ASR rule IDs and enforcement modes.'
    Adapter     = 'AuditCompat300'
    CompatId    = 84
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
