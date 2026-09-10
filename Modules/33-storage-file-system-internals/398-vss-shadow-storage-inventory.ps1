# WinScope 11 native module
[pscustomobject]@{
    Id                = 398
    Name              = 'VSS Shadow Storage Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports VSS shadow-storage associations.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'VSS shadow storage' 'vssadmin.exe' @('list','shadowstorage') 'Shadow-storage sizing is report-only.'
    }
}
