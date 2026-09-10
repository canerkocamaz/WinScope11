# WinScope 11 native module
[pscustomobject]@{
    Id                = 482
    Name              = 'Windows Copilot Policy Snapshot'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports user and machine Windows Copilot policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($scope in @(
            @{Name='Machine';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'},
            @{Name='User';Path='HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'}
        )) {
            & $Context.RegistrySnapshot 'WindowsAI' ("Copilot policy / {0}" -f $scope.Name) $scope.Path @('TurnOffWindowsCopilot') 'Copilot availability and policy names can change across Windows releases.'
        }
    }
}
