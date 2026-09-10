# WinScope 11 native module
[pscustomobject]@{
    Id                = 456
    Name              = 'Remote Management Users Group Membership'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports members of the local Remote Management Users group.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Remote Management Users group' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'LocalAccounts cmdlets may be unavailable in some PowerShell environments.' $null
        } else {
            try {
                $members=@(Get-LocalGroupMember -Group 'Remote Management Users' -ErrorAction Stop)
                if($members.Count -eq 0) {
                    & $Context.NewFinding 'Identity' 'Remote Management Users group' 'NoData' 'The local group contains no returned members.' 'Remote-management membership should align with approved WinRM/PowerShell Remoting administration.' $null
                } else {
                    foreach($m in $members) {
                        & $Context.NewFinding 'Identity' $m.Name 'Info' ("ObjectClass={0}; PrincipalSource={1}; SID={2}" -f $m.ObjectClass,$m.PrincipalSource,$m.SID) 'Remote-management membership should align with approved WinRM/PowerShell Remoting administration.' $null
                    }
                }
            } catch {
                & $Context.NewFinding 'Identity' 'Remote Management Users group' 'Unavailable' $_.Exception.Message 'The localized built-in group name may differ; this check is report-only.' $null
            }
        }
    }
}
