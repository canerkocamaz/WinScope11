# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 6
    Name        = 'Hibernation / hiberfil.sys'
    Group       = 'Power & Sleep'
    GroupId     = 11
    Flags       = '[R][A][S]'
    Description = 'Reports hibernation state and hiberfil.sys size; optional disable after confirmation.'
    Adapter     = 'AuditCompat300'
    CompatId    = 6
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
