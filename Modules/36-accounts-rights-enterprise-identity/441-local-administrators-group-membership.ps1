# WinScope 11 native module
[pscustomobject]@{
    Id                = 441
    Name              = 'Local Administrators Group Membership'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports members of the local Administrators group.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Administrators group' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'LocalAccounts cmdlets may be unavailable in 32-bit PowerShell or some environments.' $null
        } else {
            try {
                foreach($m in @(Get-LocalGroupMember -Group 'Administrators' -ErrorAction Stop)) {
                    & $Context.NewFinding 'Identity' $m.Name 'Review' ("ObjectClass={0}; PrincipalSource={1}; SID={2}" -f $m.ObjectClass,$m.PrincipalSource,$m.SID) 'Administrator membership should be minimal, documented, and periodically reviewed.' $null
                }
            } catch {
                & $Context.NewFinding 'Identity' 'Administrators group' 'Unavailable' $_.Exception.Message 'The localized group name may differ; SID-based resolution can be added in a later hardening pass.' $null
            }
        }
    }
}
