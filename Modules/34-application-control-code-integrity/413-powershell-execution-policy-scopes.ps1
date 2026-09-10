# WinScope 11 native module
[pscustomobject]@{
    Id                = 413
    Name              = 'PowerShell Execution Policy Scopes'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports PowerShell execution policy across all scopes.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $policies=Get-ExecutionPolicy -List -ErrorAction Stop
            foreach($p in $policies) {
                & $Context.NewFinding 'ApplicationControl' ([string]$p.Scope) 'Info' ("ExecutionPolicy={0}" -f $p.ExecutionPolicy) 'Execution Policy is not a security boundary by itself; review together with application control and script logging.' $null
            }
        } catch {
            & $Context.NewFinding 'ApplicationControl' 'PowerShell execution policy' 'Unavailable' $_.Exception.Message 'PowerShell policy could not be enumerated.' $null
        }
    }
}
