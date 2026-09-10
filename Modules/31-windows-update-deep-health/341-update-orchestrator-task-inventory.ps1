# WinScope 11 native module
[pscustomobject]@{
    Id                = 341
    Name              = 'Update Orchestrator Task Inventory'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports Windows Update Orchestrator scheduled tasks.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root='\Microsoft\Windows\UpdateOrchestrator\'
        try {
            $tasks=@(Get-ScheduledTask -TaskPath $root -ErrorAction Stop | Sort-Object TaskName)
            if($tasks.Count -eq 0) {
                & $Context.NewFinding 'WindowsUpdateDeep' 'Update Orchestrator tasks' 'NoData' 'No UpdateOrchestrator scheduled tasks were returned.' 'Task availability varies by Windows build.' $null
            } else {
                foreach($t in $tasks) {
                    & $Context.NewFinding 'WindowsUpdateDeep' $t.TaskName ([string]$t.State) ("Path={0}; Author={1}" -f $t.TaskPath,$t.Author) 'Windows Update orchestrator tasks are system-managed; report-only.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'WindowsUpdateDeep' 'Update Orchestrator tasks' 'Unavailable' $_.Exception.Message 'Administrator rights or task availability may affect this check.' $null
        }
    }
}
