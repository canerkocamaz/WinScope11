# WinScope 11 native module
[pscustomobject]@{
    Id                = 457
    Name              = 'Local Account Lockout State'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports local users that are currently locked out according to Get-LocalUser.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalUser -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Locked local accounts' 'Unavailable' 'Get-LocalUser is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            $locked=@(Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {$_.LockedOut})
            if($locked.Count -eq 0) {
                & $Context.NewFinding 'Identity' 'Locked local accounts' 'Healthy' 'No locked-out local accounts were returned.' 'No action required based on this check.' $null
            } else {
                foreach($u in $locked) {
                    & $Context.NewFinding 'Identity' $u.Name 'LockedOut' ("Enabled={0}; LastLogon={1}; SID={2}" -f $u.Enabled,$u.LastLogon,$u.SID) 'Investigate lockout cause and account ownership before unlocking.' $null
                }
            }
        }
    }
}
