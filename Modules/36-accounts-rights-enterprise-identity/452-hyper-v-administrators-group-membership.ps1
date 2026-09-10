# WinScope 11 native module
[pscustomobject]@{
    Id                = 452
    Name              = 'Hyper-V Administrators Group Membership'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports members of the local Hyper-V Administrators group.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Hyper-V Administrators group' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'LocalAccounts cmdlets may be unavailable in some PowerShell environments.' $null
        } else {
            try {
                $members=@(Get-LocalGroupMember -Group 'Hyper-V Administrators' -ErrorAction Stop)
                if($members.Count -eq 0) {
                    & $Context.NewFinding 'Identity' 'Hyper-V Administrators group' 'NoData' 'The local group contains no returned members.' 'Hyper-V administrative membership grants powerful virtualization-management capabilities and should be restricted.' $null
                } else {
                    foreach($m in $members) {
                        & $Context.NewFinding 'Identity' $m.Name 'Info' ("ObjectClass={0}; PrincipalSource={1}; SID={2}" -f $m.ObjectClass,$m.PrincipalSource,$m.SID) 'Hyper-V administrative membership grants powerful virtualization-management capabilities and should be restricted.' $null
                    }
                }
            } catch {
                & $Context.NewFinding 'Identity' 'Hyper-V Administrators group' 'Unavailable' $_.Exception.Message 'The localized built-in group name may differ; this check is report-only.' $null
            }
        }
    }
}
