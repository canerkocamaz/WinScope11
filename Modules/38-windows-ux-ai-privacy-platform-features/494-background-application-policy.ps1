# WinScope 11 native module
[pscustomobject]@{
    Id                = 494
    Name              = 'Background Application Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports selected Windows background application policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'App Privacy policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' @('LetAppsRunInBackground','LetAppsAccessLocation','LetAppsAccessCamera','LetAppsAccessMicrophone') 'App privacy policy may use additional ForceAllow/ForceDeny app lists; this snapshot reports top-level policy only.'
    }
}
