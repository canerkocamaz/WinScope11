# WinScope 11 native module
[pscustomobject]@{
    Id                = 394
    Name              = 'ReFS Volume Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports ReFS volumes when present.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$vs=@(Get-Volume -ErrorAction Stop|Where-Object {$_.FileSystem -eq 'ReFS'});if($vs.Count -eq 0){& $Context.NewFinding 'StorageInternals' 'ReFS volumes' 'NoData' 'No ReFS volumes found.' 'No action required.' $null}else{foreach($v in $vs){$n=if($v.DriveLetter){"$($v.DriveLetter):"}else{$v.UniqueId};& $Context.NewFinding 'StorageInternals' $n ([string]$v.HealthStatus) ("Size={0}; Free={1}; AllocationUnit={2}" -f $v.Size,$v.SizeRemaining,$v.AllocationUnitSize) 'ReFS availability depends on Windows edition/storage role.' ([long]$v.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'ReFS volumes' 'Unavailable' $_.Exception.Message 'Get-Volume failed.' $null}
    }
}
