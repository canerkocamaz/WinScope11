# WinScope 11 native module
[pscustomobject]@{
    Id                = 415
    Name              = 'PowerShell Script Block Logging Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports Script Block Logging policy settings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'ApplicationControl' 'PowerShell ScriptBlockLogging' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' @('EnableScriptBlockLogging','EnableScriptBlockInvocationLogging') 'Script Block Logging improves PowerShell visibility and may be centrally managed.'
    }
}
