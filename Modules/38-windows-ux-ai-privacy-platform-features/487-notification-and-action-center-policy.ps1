# WinScope 11 native module
[pscustomobject]@{
    Id                = 487
    Name              = 'Notification and Action Center Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows notification and Action Center configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'WindowsUX' 'Push Notifications' 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' @('ToastEnabled') 'Notification settings affect user-facing alerts.'
        & $Context.RegistrySnapshot 'WindowsUX' 'Explorer notification policy' 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' @('DisableNotificationCenter') 'Notification Center policy can be centrally managed.'
    }
}
