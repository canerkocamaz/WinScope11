# WinScope 11 native module
[pscustomobject]@{
    Id                = 391
    Name              = 'Mount Point and Access Path Inventory'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports volume access paths and mount points.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($p in @(Get-Partition -ErrorAction Stop|Where-Object {$_.AccessPaths.Count -gt 0})){foreach($a in $p.AccessPaths){& $Context.NewFinding 'StorageInternals' ("Disk {0} Partition {1}" -f $p.DiskNumber,$p.PartitionNumber) 'Info' ("AccessPath={0}; Type={1}; Size={2}" -f $a,$p.Type,$p.Size) 'Mount points are normal Windows storage constructs.' ([long]$p.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'Mount points' 'Unavailable' $_.Exception.Message 'Get-Partition failed.' $null}
    }
}
