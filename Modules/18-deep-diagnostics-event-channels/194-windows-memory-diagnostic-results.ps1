# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 194
    Name        = 'Windows Memory Diagnostic Results'
    Group       = 'Deep Diagnostics & Event Channels'
    GroupId     = 18
    Flags       = '[R][A][S]'
    Description = 'Reports recent Windows Memory Diagnostic result events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 194
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
