# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 176
    Name        = 'Microsoft Defender Application Guard'
    Group       = 'Identity & Security Policy'
    GroupId     = 17
    Flags       = '[R][A][S]'
    Description = 'Reports Application Guard feature state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 176
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
