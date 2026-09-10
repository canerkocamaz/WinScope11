# WinScope 11 native module
[pscustomobject]@{
    Id                = 420
    Name              = 'Windows Script Host Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports machine and user Windows Script Host enable/disable policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($scope in @(
            @{Name='Machine';Path='HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings'},
            @{Name='User';Path='HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings'}
        )) {
            if(Test-Path -LiteralPath $scope.Path) {
                $v=(Get-ItemProperty -LiteralPath $scope.Path -Name Enabled -ErrorAction SilentlyContinue).Enabled
                & $Context.NewFinding 'ApplicationControl' ("Windows Script Host / {0}" -f $scope.Name) 'Info' ("Enabled={0}" -f $v) 'Windows Script Host can be restricted in hardened environments; compatibility requirements should be considered.' $null
            } else {
                & $Context.NewFinding 'ApplicationControl' ("Windows Script Host / {0}" -f $scope.Name) 'NotConfigured' 'No explicit Enabled value was found.' 'NotConfigured normally means default Windows behavior applies.' $null
            }
        }
    }
}
