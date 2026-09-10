# WinScope 11 native module
[pscustomobject]@{
    Id                = 486
    Name              = 'Search and Cloud Suggestions Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports selected Windows Search web/cloud suggestion policies.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'Windows Search policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' @('AllowCloudSearch','ConnectedSearchUseWeb','DisableWebSearch','AllowCortana','AllowSearchToUseLocation') 'Search web/cloud integration settings affect privacy and user experience; names vary by Windows release.'
    }
}
