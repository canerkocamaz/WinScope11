# WinScope 11 native module
[pscustomobject]@{
    Id                = 448
    Name              = 'Orphaned User Profile SID Cross-Check'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Cross-checks local user profiles against resolvable account SIDs.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            foreach($p in @(Get-CimInstance Win32_UserProfile -ErrorAction Stop | Where-Object {-not $_.Special})) {
                $resolved=$true
                $name=''
                try {
                    $sid=New-Object System.Security.Principal.SecurityIdentifier($p.SID)
                    $acct=$sid.Translate([System.Security.Principal.NTAccount])
                    $name=$acct.Value
                } catch {
                    $resolved=$false
                }
                & $Context.NewFinding 'Identity' $p.LocalPath $(if($resolved){'Resolved'}else{'Orphaned?'}) ("SID={0}; Account={1}; Loaded={2}; LastUse={3}" -f $p.SID,$name,$p.Loaded,$p.LastUseTime) 'Unresolvable profile SIDs can be stale or belong to unavailable domains; never delete a profile solely from this check.' $null
            }
        } catch {
            & $Context.NewFinding 'Identity' 'User profile SID cross-check' 'Unavailable' $_.Exception.Message 'Win32_UserProfile inventory failed.' $null
        }
    }
}
