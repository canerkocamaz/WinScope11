# WinScope 11 native module
[pscustomobject]@{
    Id                = 488
    Name              = 'Clipboard History and Cloud Sync Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports clipboard history and cloud clipboard policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'Clipboard policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' @('AllowClipboardHistory','AllowCrossDeviceClipboard') 'Clipboard history and cross-device sync can contain sensitive copied content; policy should reflect privacy requirements.'
        & $Context.RegistrySnapshot 'Privacy' 'Current user clipboard' 'HKCU:\Software\Microsoft\Clipboard' @('EnableClipboardHistory','CloudClipboardAutomaticUpload') 'Current-user values are informational.'
    }
}
