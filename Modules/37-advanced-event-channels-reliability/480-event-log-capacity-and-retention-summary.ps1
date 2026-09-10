# WinScope 11 native module
[pscustomobject]@{
    Id                = 480
    Name              = 'Event Log Capacity and Retention Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports size, record count, mode, and enabled state for key Windows event channels.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $logs=@(
            'System','Application','Security',
            'Microsoft-Windows-PowerShell/Operational',
            'Microsoft-Windows-Windows Defender/Operational',
            'Microsoft-Windows-TaskScheduler/Operational',
            'Microsoft-Windows-CodeIntegrity/Operational'
        )
        foreach($log in $logs) {
            try {
                $i=Get-WinEvent -ListLog $log -ErrorAction Stop
                & $Context.NewFinding 'Reliability' $log $(if($i.IsEnabled){'Enabled'}else{'Disabled'}) ("Records={0}; MaxSize={1}; FileSize={2}; LogMode={3}; Retention={4}; AutoBackup={5}" -f $i.RecordCount,$i.MaximumSizeInBytes,$i.FileSize,$i.LogMode,$i.IsLogFull,$i.AutoBackupLogFiles) 'Event-log capacity should support operational/security retention requirements without causing excessive disk growth.' ([long]$i.FileSize)
            } catch {
                & $Context.NewFinding 'Reliability' $log 'Unavailable' $_.Exception.Message 'The event channel may not exist or may require elevated access.' $null
            }
        }
    }
}
