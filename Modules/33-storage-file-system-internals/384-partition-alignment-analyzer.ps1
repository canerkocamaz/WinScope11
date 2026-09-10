# WinScope 11 native module
[pscustomobject]@{
    Id                = 384
    Name              = 'Partition Alignment Analyzer'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports partition offsets and 4K alignment.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($d in @(Get-Disk -ErrorAction Stop)){foreach($p in @(Get-Partition -DiskNumber $d.Number -ErrorAction SilentlyContinue)){$ok=($p.Offset % 4096 -eq 0);& $Context.NewFinding 'StorageInternals' ("Disk {0} Partition {1}" -f $d.Number,$p.PartitionNumber) $(if($ok){'Aligned'}else{'Review'}) ("Offset={0}; Size={1}; Type={2}" -f $p.Offset,$p.Size,$p.Type) 'Do not repartition based only on this check.' ([long]$p.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'Partition alignment' 'Unavailable' $_.Exception.Message 'Storage cmdlets failed.' $null}
    }
}
