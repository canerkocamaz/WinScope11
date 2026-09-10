# WinScope 11 native module
[pscustomobject]@{
    Id                = 447
    Name              = 'Dormant Local Account Review'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Flags enabled local accounts with no logon in roughly 180 days when LastLogon is available.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalUser -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Dormant local accounts' 'Unavailable' 'Get-LocalUser is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            $cutoff=(Get-Date).AddDays(-180)
            $users=@(Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -and $_.LastLogon -and $_.LastLogon -lt $cutoff})
            if($users.Count -eq 0) {
                & $Context.NewFinding 'Identity' 'Dormant local accounts' 'NoData' 'No enabled accounts with LastLogon older than 180 days were returned.' 'LastLogon may be missing or incomplete for some account types.' $null
            } else {
                foreach($u in $users) {
                    & $Context.NewFinding 'Identity' $u.Name 'Review' ("LastLogon={0}; SID={1}; Description={2}" -f $u.LastLogon,$u.SID,$u.Description) 'Confirm ownership and business need before disabling or removing an account.' $null
                }
            }
        }
    }
}
