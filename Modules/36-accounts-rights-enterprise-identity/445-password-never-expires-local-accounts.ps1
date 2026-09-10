# WinScope 11 native module
[pscustomobject]@{
    Id                = 445
    Name              = 'Password Never Expires Local Accounts'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports local accounts configured with PasswordNeverExpires.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalUser -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'PasswordNeverExpires accounts' 'Unavailable' 'Get-LocalUser is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            $users=@(Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {$_.PasswordNeverExpires})
            if($users.Count -eq 0) {
                & $Context.NewFinding 'Identity' 'PasswordNeverExpires accounts' 'Healthy' 'No local accounts with PasswordNeverExpires were returned.' 'No action required based on this check.' $null
            } else {
                foreach($u in $users) {
                    & $Context.NewFinding 'Identity' $u.Name 'Review' ("Enabled={0}; SID={1}; LastLogon={2}" -f $u.Enabled,$u.SID,$u.LastLogon) 'Password-never-expires accounts should have a documented requirement or use managed service-account alternatives where appropriate.' $null
                }
            }
        }
    }
}
