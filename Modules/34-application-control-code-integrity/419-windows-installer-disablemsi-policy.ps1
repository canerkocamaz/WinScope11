# WinScope 11 native module
[pscustomobject]@{
    Id                = 419
    Name              = 'Windows Installer DisableMSI Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports the Windows Installer DisableMSI policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'ApplicationControl' 'Windows Installer policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' @('DisableMSI','DisableUserInstalls','EnableUserControl') 'Windows Installer restrictions can affect software deployment and should match enterprise application-management policy.'
    }
}
