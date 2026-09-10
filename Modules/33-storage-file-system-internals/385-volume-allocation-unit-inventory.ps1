# WinScope 11 native module
[pscustomobject]@{
    Id                = 385
    Name              = 'Volume Allocation Unit Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports file system and allocation unit size.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($v in @(Get-Volume -ErrorAction Stop)){if($v.Size -gt 0){$name=if($v.DriveLetter){"$($v.DriveLetter):"}else{$v.UniqueId};& $Context.NewFinding 'StorageInternals' $name ([string]$v.HealthStatus) ("FileSystem={0}; AllocationUnit={1}; Free={2}" -f $v.FileSystem,$v.AllocationUnitSize,$v.SizeRemaining) 'Allocation unit size is report-only.' ([long]$v.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'Volumes' 'Unavailable' $_.Exception.Message 'Get-Volume failed.' $null}
    }
}
