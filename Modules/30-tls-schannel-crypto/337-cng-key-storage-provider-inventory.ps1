# WinScope 11 native module
[pscustomobject]@{
    Id                = 337
    Name              = 'CNG Key Storage Provider Inventory'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports cryptographic providers returned by certutil -csplist.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd = Get-Command 'certutil.exe' -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Crypto' 'Cryptographic providers' 'Unavailable' 'certutil.exe was not found.' 'Provider inventory is informational and does not access private key material.' $null
        } else {
            try {
                $output = (& $cmd.Source @('-csplist') 2>&1 | Out-String).Trim()
                if([string]::IsNullOrWhiteSpace($output)) {$output='Command returned no text output.'}
                & $Context.NewFinding 'Crypto' 'Cryptographic providers' 'Info' $output 'Provider inventory is informational and does not access private key material.' $null
            } catch {
                & $Context.NewFinding 'Crypto' 'Cryptographic providers' 'Error' $_.Exception.Message 'Provider inventory is informational and does not access private key material.' $null
            }
        }
    }
}
