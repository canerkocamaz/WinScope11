# WinScope 11 native module
[pscustomobject]@{
    Id                = 414
    Name              = 'PowerShell Language Mode'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports the current PowerShell session language mode.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $mode=$ExecutionContext.SessionState.LanguageMode
        & $Context.NewFinding 'ApplicationControl' 'PowerShell LanguageMode' 'Info' ("LanguageMode={0}" -f $mode) 'Constrained Language Mode can be imposed by application-control technologies; current session state is informational.' $null
    }
}
