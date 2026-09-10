# WinScope 11 native module
[pscustomobject]@{
    Id                = 442
    Name              = 'Remote Desktop Users Group Membership'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports members of the local Remote Desktop Users group.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Remote Desktop Users group' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            try {
                foreach($m in @(Get-LocalGroupMember -Group 'Remote Desktop Users' -ErrorAction Stop)) {
                    & $Context.NewFinding 'Identity' $m.Name 'Review' ("ObjectClass={0}; PrincipalSource={1}; SID={2}" -f $m.ObjectClass,$m.PrincipalSource,$m.SID) 'Remote Desktop access should be limited to explicitly authorized principals.' $null
                }
            } catch {
                & $Context.NewFinding 'Identity' 'Remote Desktop Users group' 'Unavailable' $_.Exception.Message 'The localized group name may differ.' $null
            }
        }
    }
}
