# WinScope 11 native module
[pscustomobject]@{
    Id                = 400
    Name              = 'Storage Posture Summary'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Provides compact per-volume health and free-space summary.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($v in @(Get-Volume -ErrorAction Stop|Where-Object {$_.DriveLetter -and $_.Size -gt 0})){$pct=[math]::Round(($v.SizeRemaining/$v.Size)*100,1);$st=if($v.HealthStatus -ne 'Healthy'){'HealthWarning'}elseif($pct -lt 10){'LowSpace'}elseif($pct -lt 20){'Review'}else{'Healthy'};& $Context.NewFinding 'StorageInternals' ("$($v.DriveLetter):") $st ("FileSystem={0}; Health={1}; FreePercent={2}; Free={3}; AllocationUnit={4}" -f $v.FileSystem,$v.HealthStatus,$pct,$v.SizeRemaining,$v.AllocationUnitSize) 'Use specific storage modules to investigate warnings.' ([long]$v.Size)}}catch{& $Context.NewFinding 'StorageInternals' 'Storage posture' 'Unavailable' $_.Exception.Message 'Get-Volume failed.' $null}
    }
}
