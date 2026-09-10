# WinScope 11 native module
[pscustomobject]@{
    Id                = 389
    Name              = 'NTFS Compression Behavior'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports NTFS compression behavior policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'NTFS compression' 'fsutil.exe' @('behavior','query','disablecompression') 'Compression support changes can affect application compatibility.'
    }
}
