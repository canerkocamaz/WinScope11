# WinScope 11 native module
[pscustomobject]@{
    Id                = 301
    Name              = 'Kerberos Ticket Cache Inventory'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports the current logon session Kerberos ticket cache using klist.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd = Get-Command 'klist.exe' -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Authentication' 'Kerberos ticket cache' 'Unavailable' 'klist.exe was not found.' 'Kerberos tickets are authentication metadata. This module does not purge or request tickets.' $null
        } else {
            try {
                $output = (& $cmd.Source @() 2>&1 | Out-String).Trim()
                if([string]::IsNullOrWhiteSpace($output)) {$output='Command returned no text output.'}
                & $Context.NewFinding 'Authentication' 'Kerberos ticket cache' 'Info' $output 'Kerberos tickets are authentication metadata. This module does not purge or request tickets.' $null
            } catch {
                & $Context.NewFinding 'Authentication' 'Kerberos ticket cache' 'Error' $_.Exception.Message 'Kerberos tickets are authentication metadata. This module does not purge or request tickets.' $null
            }
        }
    }
}
