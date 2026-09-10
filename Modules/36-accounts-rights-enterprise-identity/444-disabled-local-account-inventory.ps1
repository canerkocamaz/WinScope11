# WinScope 11 native module
[pscustomobject]@{
    Id                = 444
    Name              = 'Disabled Local Account Inventory'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports disabled local user accounts.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalUser -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Disabled local accounts' 'Unavailable' 'Get-LocalUser is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            $users=@(Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {-not $_.Enabled})
            if($users.Count -eq 0) {
                & $Context.NewFinding 'Identity' 'Disabled local accounts' 'NoData' 'No disabled local accounts were returned.' 'No action required.' $null
            } else {
                foreach($u in $users) {
                    & $Context.NewFinding 'Identity' $u.Name 'Disabled' ("SID={0}; LastLogon={1}; Description={2}" -f $u.SID,$u.LastLogon,$u.Description) 'Disabled accounts may be intentional; review stale accounts before deletion.' $null
                }
            }
        }
    }
}
