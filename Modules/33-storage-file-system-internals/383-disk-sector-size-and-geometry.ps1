# WinScope 11 native module
[pscustomobject]@{
    Id                = 383
    Name              = 'Disk Sector Size and Geometry'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports disk sector sizes, partition style and state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($d in @(Get-Disk -ErrorAction Stop)){& $Context.NewFinding 'StorageInternals' ("Disk {0}" -f $d.Number) ([string]$d.OperationalStatus) ("Name={0}; PartitionStyle={1}; LogicalSector={2}; PhysicalSector={3}; Boot={4}; System={5}; Offline={6}; ReadOnly={7}" -f $d.FriendlyName,$d.PartitionStyle,$d.LogicalSectorSize,$d.PhysicalSectorSize,$d.IsBoot,$d.IsSystem,$d.IsOffline,$d.IsReadOnly) 'Disk geometry is report-only.' ([long]$d.Size)}}catch{& $Context.NewFinding 'StorageInternals' 'Disk geometry' 'Unavailable' $_.Exception.Message 'Get-Disk failed.' $null}
    }
}
