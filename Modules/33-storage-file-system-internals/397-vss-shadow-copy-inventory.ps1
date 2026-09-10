# WinScope 11 native module
[pscustomobject]@{
    Id                = 397
    Name              = 'VSS Shadow Copy Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports Volume Shadow Copy snapshots.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'VSS shadows' 'vssadmin.exe' @('list','shadows') 'Shadow copies support recovery; this module does not delete them.'
    }
}
