# WinScope 11 native module
[pscustomobject]@{
    Id                = 312
    Name              = 'Windows Hello Provisioning Policy'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports selected Windows Hello for Business provisioning policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks = @(
            @{Item='PassportForWork';Path='HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork';Names=@('Enabled','DisablePostLogonProvisioning','RequireSecurityDevice','UseCertificateForOnPremAuth')}
        )
        foreach($check in $checks) {
            if(-not (Test-Path -LiteralPath $check.Path)) {
                & $Context.NewFinding 'Authentication' $check.Item 'NotConfigured' ("Registry path not present: {0}" -f $check.Path) 'Windows Hello for Business is commonly managed through Group Policy or MDM.' $null
                continue
            }
            $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction SilentlyContinue
            if($null -eq $p) {
                & $Context.NewFinding 'Authentication' $check.Item 'Unavailable' ("Registry path could not be read: {0}" -f $check.Path) 'Windows Hello for Business is commonly managed through Group Policy or MDM.' $null
                continue
            }
            if($check.Names.Count -eq 0) {
                $pairs = @($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value })
                & $Context.NewFinding 'Authentication' $check.Item 'Info' ($pairs -join '; ') 'Windows Hello for Business is commonly managed through Group Policy or MDM.' $null
            } else {
                foreach($name in $check.Names) {
                    if($p.PSObject.Properties.Name -contains $name) {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'Info' ("Value={0}" -f $p.$name) 'Windows Hello for Business is commonly managed through Group Policy or MDM.' $null
                    } else {
                        & $Context.NewFinding 'Authentication' ("{0} / {1}" -f $check.Item,$name) 'NotConfigured' 'Value is not explicitly configured.' 'Windows Hello for Business is commonly managed through Group Policy or MDM.' $null
                    }
                }
            }
        }
    }
}
