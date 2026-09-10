# WinScope 11 native module
[pscustomobject]@{
    Id                = 450
    Name              = 'Local Password and Lockout Policy Summary'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports local password and account lockout policy through net accounts.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Identity' 'Local account policy' 'net.exe' @('accounts') 'Password/lockout policy should be compared with domain or MDM policy when the device is managed.'
    }
}
