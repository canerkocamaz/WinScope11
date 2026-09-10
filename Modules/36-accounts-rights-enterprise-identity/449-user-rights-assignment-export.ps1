# WinScope 11 native module
[pscustomobject]@{
    Id                = 449
    Name              = 'Current Token Privilege Snapshot'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports the current process token privilege set without exporting local security policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)

        & $Context.CommandSnapshot `
            'Identity' `
            'Current token privileges' `
            'whoami.exe' `
            @('/priv') `
            'Safe Audit Edition reports the current token privilege set without exporting or modifying local security policy.'
    }
}
