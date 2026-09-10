# WinScope 11 native module
[pscustomobject]@{
    Id                = 455
    Name              = 'Performance Log Users Group Membership'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports members of the local Performance Log Users group.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Performance Log Users group' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'LocalAccounts cmdlets may be unavailable in some PowerShell environments.' $null
        } else {
            try {
                $members=@(Get-LocalGroupMember -Group 'Performance Log Users' -ErrorAction Stop)
                if($members.Count -eq 0) {
                    & $Context.NewFinding 'Identity' 'Performance Log Users group' 'NoData' 'The local group contains no returned members.' 'Performance logging rights can expose sensitive system telemetry; membership should be intentional.' $null
                } else {
                    foreach($m in $members) {
                        & $Context.NewFinding 'Identity' $m.Name 'Info' ("ObjectClass={0}; PrincipalSource={1}; SID={2}" -f $m.ObjectClass,$m.PrincipalSource,$m.SID) 'Performance logging rights can expose sensitive system telemetry; membership should be intentional.' $null
                    }
                }
            } catch {
                & $Context.NewFinding 'Identity' 'Performance Log Users group' 'Unavailable' $_.Exception.Message 'The localized built-in group name may differ; this check is report-only.' $null
            }
        }
    }
}
