# WinScope 11 native module
[pscustomobject]@{
    Id                = 302
    Name              = 'Kerberos Session List'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports Kerberos logon sessions when supported by the local klist implementation.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd = Get-Command 'klist.exe' -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Authentication' 'Kerberos sessions' 'Unavailable' 'klist.exe was not found.' 'Session output is informational and no logon session is modified.' $null
        } else {
            try {
                $output = (& $cmd.Source @('sessions') 2>&1 | Out-String).Trim()
                if([string]::IsNullOrWhiteSpace($output)) {$output='Command returned no text output.'}
                & $Context.NewFinding 'Authentication' 'Kerberos sessions' 'Info' $output 'Session output is informational and no logon session is modified.' $null
            } catch {
                & $Context.NewFinding 'Authentication' 'Kerberos sessions' 'Error' $_.Exception.Message 'Session output is informational and no logon session is modified.' $null
            }
        }
    }
}
