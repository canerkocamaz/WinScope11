# WinScope 11 native module
[pscustomobject]@{
    Id                = 498
    Name              = 'Windows Hello and Sign-in Policy Summary'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports selected Windows Hello/sign-in policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'WindowsUX' 'Windows Hello for Business' 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' @('Enabled','RequireSecurityDevice','DisablePostLogonProvisioning') 'Windows Hello for Business policy can be centrally managed.'
        & $Context.RegistrySnapshot 'WindowsUX' 'System sign-in policy' 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' @('DontDisplayLastUserName','DisableCAD') 'Sign-in UI policy affects usability and information disclosure.'
    }
}
