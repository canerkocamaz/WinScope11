# WinScope 11 native module
[pscustomobject]@{
    Id                = 417
    Name              = 'PowerShell Transcription Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports PowerShell transcription policy settings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'ApplicationControl' 'PowerShell Transcription' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' @('EnableTranscripting','EnableInvocationHeader','OutputDirectory') 'Transcription can contain sensitive command output; storage and access controls should be reviewed.'
    }
}
