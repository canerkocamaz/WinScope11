# WinScope 11 native module
[pscustomobject]@{
    Id                = 390
    Name              = 'NTFS Symlink Evaluation Policy'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports symbolic-link evaluation policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'StorageInternals' 'Symlink evaluation' 'fsutil.exe' @('behavior','query','SymlinkEvaluation') 'Symlink evaluation affects local/remote link behavior.'
    }
}
