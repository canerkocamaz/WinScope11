# WinScope 11 native module
[pscustomobject]@{
    Id                = 495
    Name              = 'Diagnostic Data and Telemetry Policy'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows diagnostic data/telemetry policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'DataCollection policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' @('AllowTelemetry','AllowDiagnosticData','LimitDiagnosticLogCollection','LimitDumpCollection','DisableOneSettingsDownloads') 'Diagnostic-data policy names/semantics vary across Windows releases and editions.'
    }
}
