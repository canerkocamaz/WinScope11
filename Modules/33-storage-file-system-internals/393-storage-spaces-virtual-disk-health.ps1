# WinScope 11 native module
[pscustomobject]@{
    Id                = 393
    Name              = 'Storage Spaces Virtual Disk Health'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports Storage Spaces virtual disk resiliency and health.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$vds=@(Get-VirtualDisk -ErrorAction Stop);if($vds.Count -eq 0){& $Context.NewFinding 'StorageInternals' 'Virtual disks' 'NoData' 'No Storage Spaces virtual disks found.' 'No action required.' $null}else{foreach($v in $vds){& $Context.NewFinding 'StorageInternals' $v.FriendlyName ([string]$v.HealthStatus) ("Operational={0}; Resiliency={1}; Provisioning={2}; Footprint={3}" -f ($v.OperationalStatus -join ','),$v.ResiliencySettingName,$v.ProvisioningType,$v.FootprintOnPool) 'Degraded virtual disks require pool/disk investigation.' ([long]$v.Size)}}}catch{& $Context.NewFinding 'StorageInternals' 'Virtual disks' 'Unavailable' $_.Exception.Message 'Storage Spaces may be unavailable.' $null}
    }
}
