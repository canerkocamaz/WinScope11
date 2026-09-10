# WinScope 11 native module
[pscustomobject]@{
    Id                = 481
    Name              = 'Windows Recall Policy Snapshot'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows AI/Recall-related policy values when present.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($scope in @(
            @{Name='Machine';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'},
            @{Name='User';Path='HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'}
        )) {
            & $Context.RegistrySnapshot 'WindowsAI' ("Recall policy / {0}" -f $scope.Name) $scope.Path @('DisableAIDataAnalysis','AllowRecallEnablement','DisableRecall') 'Recall/AI policy availability varies by Windows build, Copilot+ hardware, region, and management state.'
        }
    }
}
