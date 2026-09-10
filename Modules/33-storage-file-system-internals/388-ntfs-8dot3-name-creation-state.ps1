# WinScope 11 native module
[pscustomobject]@{
    Id                = 388
    Name              = 'NTFS 8dot3 Name Creation State'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports NTFS 8.3 name-creation policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'NTFS 8.3' 'fsutil.exe' @('behavior','query','disable8dot3') '8.3 names may be needed by legacy applications.'
    }
}
