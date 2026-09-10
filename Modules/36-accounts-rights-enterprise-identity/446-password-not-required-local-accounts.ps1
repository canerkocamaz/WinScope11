# WinScope 11 native module
[pscustomobject]@{
    Id                = 446
    Name              = 'Password Not Required Local Accounts'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports local accounts whose PasswordRequired flag is false through Win32_UserAccount.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $users=@(Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' -ErrorAction Stop | Where-Object {$_.PasswordRequired -eq $false})
            if($users.Count -eq 0) {
                & $Context.NewFinding 'Identity' 'Password not required accounts' 'Healthy' 'No local accounts with PasswordRequired=False were returned.' 'No action required based on this check.' $null
            } else {
                foreach($u in $users) {
                    & $Context.NewFinding 'Identity' $u.Name 'Warning' ("SID={0}; Disabled={1}; Lockout={2}" -f $u.SID,$u.Disabled,$u.Lockout) 'Local accounts that do not require a password should be reviewed carefully, especially if enabled.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'Identity' 'Password not required accounts' 'Unavailable' $_.Exception.Message 'Win32_UserAccount query failed.' $null
        }
    }
}
