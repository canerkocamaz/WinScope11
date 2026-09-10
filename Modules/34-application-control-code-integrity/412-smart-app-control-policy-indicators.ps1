# WinScope 11 native module
[pscustomobject]@{
    Id                = 412
    Name              = 'Smart App Control Policy Indicators'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports Windows Code Integrity registry indicators associated with reputation-based application control.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'ApplicationControl' 'Code Integrity policy indicators' 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' @('VerifiedAndReputablePolicyState','SkuPolicyRequired') 'These low-level values vary by Windows release; treat them as indicators rather than a standalone Smart App Control verdict.'
    }
}
