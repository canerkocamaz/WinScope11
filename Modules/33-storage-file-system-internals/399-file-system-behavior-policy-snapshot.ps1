# WinScope 11 native module
[pscustomobject]@{
    Id                = 399
    Name              = 'File System Behavior Policy Snapshot'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports selected file-system policy registry values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'StorageInternals' 'FileSystem policy' 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' @('LongPathsEnabled','NtfsDisable8dot3NameCreation','NtfsDisableLastAccessUpdate','NtfsDisableCompression','RefsDisableLastAccessUpdate') 'File-system policy can affect compatibility/performance; report-only.'
    }
}
