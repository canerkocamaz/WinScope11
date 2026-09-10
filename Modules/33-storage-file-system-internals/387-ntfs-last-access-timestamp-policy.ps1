# WinScope 11 native module
[pscustomobject]@{
    Id                = 387
    Name              = 'NTFS Last Access Timestamp Policy'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports NTFS last-access update behavior.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'NTFS last access' 'fsutil.exe' @('behavior','query','disablelastaccess') 'Last-access behavior affects metadata writes and some workflows.'
    }
}
