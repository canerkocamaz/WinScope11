# WinScope 11 native module
[pscustomobject]@{
    Id                = 392
    Name              = 'Storage Spaces Pool Health'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports non-primordial Storage Spaces pool health.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$pools=@(Get-StoragePool -ErrorAction Stop|Where-Object {!$_.IsPrimordial});if($pools.Count -eq 0){& $Context.NewFinding 'StorageInternals' 'Storage Spaces pools' 'NoData' 'No non-primordial pools found.' 'No action required.' $null}else{foreach($p in $pools){& $Context.NewFinding 'StorageInternals' $p.FriendlyName ([string]$p.HealthStatus) ("Operational={0}; Allocated={1}; ReadOnly={2}" -f ($p.OperationalStatus -join ','),$p.AllocatedSize,$p.IsReadOnly) 'Degraded pools require careful storage investigation.' ([long]$p.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'Storage Spaces pools' 'Unavailable' $_.Exception.Message 'Storage Spaces may be unavailable.' $null}
    }
}
