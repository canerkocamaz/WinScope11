# WinScope 11 native module
[pscustomobject]@{
    Id                = 418
    Name              = 'AlwaysInstallElevated Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports machine and user AlwaysInstallElevated Windows Installer policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks=@(
            @{Name='Machine';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'},
            @{Name='User';Path='HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer'}
        )
        foreach($c in $checks) {
            if(Test-Path -LiteralPath $c.Path) {
                $v=(Get-ItemProperty -LiteralPath $c.Path -Name AlwaysInstallElevated -ErrorAction SilentlyContinue).AlwaysInstallElevated
                $status=if($v -eq 1){'Warning'}else{'Info'}
                & $Context.NewFinding 'ApplicationControl' ("AlwaysInstallElevated / {0}" -f $c.Name) $status ("Value={0}" -f $v) 'Enabling AlwaysInstallElevated in both scopes can enable privilege escalation through MSI packages.' $null
            } else {
                & $Context.NewFinding 'ApplicationControl' ("AlwaysInstallElevated / {0}" -f $c.Name) 'NotConfigured' 'Policy path is absent.' 'Absence is normal when the policy is not configured.' $null
            }
        }
    }
}
