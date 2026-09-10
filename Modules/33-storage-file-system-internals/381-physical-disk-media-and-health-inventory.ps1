# WinScope 11 native module
[pscustomobject]@{
    Id                = 381
    Name              = 'Physical Disk Media and Health Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports physical disk media type, bus, size and health.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($d in @(Get-PhysicalDisk -ErrorAction Stop)){& $Context.NewFinding 'StorageInternals' $d.FriendlyName ([string]$d.HealthStatus) ("MediaType={0}; BusType={1}; Size={2}; Operational={3}" -f $d.MediaType,$d.BusType,$d.Size,($d.OperationalStatus -join ',')) 'Investigate degraded/unhealthy storage before maintenance.' ([long]$d.Size)}}catch{& $Context.NewFinding 'StorageInternals' 'Physical disks' 'Unavailable' $_.Exception.Message 'Storage cmdlets may be unavailable.' $null}
    }
}
