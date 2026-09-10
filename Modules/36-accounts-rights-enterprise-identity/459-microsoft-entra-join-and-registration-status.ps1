# WinScope 11 native module
[pscustomobject]@{
    Id                = 459
    Name              = 'Microsoft Entra Join and Registration Status'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports device join/registration state using dsregcmd /status.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'EnterpriseIdentity' 'Device registration status' 'dsregcmd.exe' @('/status') 'Review AzureAdJoined/DomainJoined/WorkplaceJoined, tenant and device state without exposing tokens or secrets.'
    }
}
