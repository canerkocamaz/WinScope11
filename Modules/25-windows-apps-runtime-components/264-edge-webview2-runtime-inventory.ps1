# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 264
    Name        = 'Edge WebView2 Runtime Inventory'
    Group       = 'Windows Apps & Runtime Components'
    GroupId     = 25
    Flags       = '[R][S]'
    Description = 'Reports installed WebView2 runtime packages.'
    Adapter     = 'AuditCompat300'
    CompatId    = 264
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
