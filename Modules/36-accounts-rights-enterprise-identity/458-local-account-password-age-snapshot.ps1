# WinScope 11 native module
[pscustomobject]@{
    Id                = 458
    Name              = 'Local Account Password Age Snapshot'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports PasswordLastSet and PasswordExpires metadata for local users.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-LocalUser -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'Identity' 'Local account password age' 'Unavailable' 'Get-LocalUser is unavailable.' 'LocalAccounts cmdlets may be unavailable.' $null
        } else {
            foreach($u in @(Get-LocalUser -ErrorAction SilentlyContinue | Sort-Object Name)) {
                $age=''
                if($u.PasswordLastSet) {
                    $age=[math]::Floor(((Get-Date)-$u.PasswordLastSet).TotalDays)
                }
                & $Context.NewFinding 'Identity' $u.Name 'Info' ("Enabled={0}; PasswordLastSet={1}; PasswordAgeDays={2}; PasswordExpires={3}; PasswordNeverExpires={4}" -f $u.Enabled,$u.PasswordLastSet,$age,$u.PasswordExpires,$u.PasswordNeverExpires) 'Interpret password age together with local/domain password policy and account purpose.' $null
            }
        }
    }
}
