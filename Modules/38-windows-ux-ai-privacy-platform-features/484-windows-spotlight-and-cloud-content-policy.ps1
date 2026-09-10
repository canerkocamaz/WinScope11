# WinScope 11 native module
[pscustomobject]@{
    Id                = 484
    Name              = 'Windows Spotlight and Cloud Content Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows Spotlight, consumer experiences, and cloud-content policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'Machine CloudContent policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' @('DisableWindowsSpotlightFeatures','DisableWindowsConsumerFeatures','DisableThirdPartySuggestions','DisableTailoredExperiencesWithDiagnosticData') 'Cloud-content policy affects Spotlight, suggestions, consumer features, and tailored experiences.'
        & $Context.RegistrySnapshot 'Privacy' 'User CloudContent policy' 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' @('DisableWindowsSpotlightFeatures','DisableWindowsSpotlightOnActionCenter','DisableWindowsSpotlightOnSettings','DisableWindowsSpotlightOnLockScreen') 'User policy can override portions of the Spotlight experience.'
    }
}
