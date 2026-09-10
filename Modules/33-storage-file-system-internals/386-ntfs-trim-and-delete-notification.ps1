# WinScope 11 native module
[pscustomobject]@{
    Id                = 386
    Name              = 'NTFS TRIM and Delete Notification'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports delete-notification/TRIM behavior.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'TRIM / delete notification' 'fsutil.exe' @('behavior','query','DisableDeleteNotify') 'Interpret by file system/device type; WinScope does not change TRIM.'
    }
}
