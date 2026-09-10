# WinScope 11 native module
[pscustomobject]@{
    Id                = 489
    Name              = 'Activity History Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports activity history/feed publishing and upload policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'Activity History policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' @('EnableActivityFeed','PublishUserActivities','UploadUserActivities') 'Activity history settings affect local/cloud activity data and can be enterprise-managed.'
    }
}
