# WinScope 11 native module
[pscustomobject]@{
    Id                = 497
    Name              = 'Tailored Experiences and Feedback Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports tailored-experience and feedback-related policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'CloudContent tailored experiences' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' @('DisableTailoredExperiencesWithDiagnosticData') 'Tailored experiences can use diagnostic data for personalized recommendations.'
        & $Context.RegistrySnapshot 'Privacy' 'DataCollection feedback' 'HKCU:\Software\Microsoft\Siuf\Rules' @('NumberOfSIUFInPeriod','PeriodInNanoSeconds') 'Feedback-frequency values can vary by Windows release.'
    }
}
