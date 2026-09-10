# WinScope 11 native module
[pscustomobject]@{
    Id                = 382
    Name              = 'Storage Reliability Counters'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports temperature, wear, power-on hours and error counters where supported.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($d in @(Get-PhysicalDisk -ErrorAction Stop)){$r=$d|Get-StorageReliabilityCounter -ErrorAction SilentlyContinue;if($null -ne $r){& $Context.NewFinding 'StorageInternals' $d.FriendlyName 'Info' ("Temperature={0}; Wear={1}; PowerOnHours={2}; ReadErrors={3}; WriteErrors={4}" -f $r.Temperature,$r.Wear,$r.PowerOnHours,$r.ReadErrorsTotal,$r.WriteErrorsTotal) 'Counters are hardware/driver dependent; trends matter more than one sample.' $null}}}catch{& $Context.NewFinding 'StorageInternals' 'Reliability counters' 'Unavailable' $_.Exception.Message 'Hardware may not expose counters.' $null}
    }
}
