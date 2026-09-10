# WinScope 11 native module
[pscustomobject]@{
    Id                = 395
    Name              = 'Data Deduplication Status'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports Data Deduplication volume state where available.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $c=Get-Command Get-DedupVolume -ErrorAction SilentlyContinue;if($null -eq $c){& $Context.NewFinding 'StorageInternals' 'Data Deduplication' 'Unavailable' 'Get-DedupVolume is unavailable.' 'Feature is not available on all Windows editions.' $null}else{$vs=@(Get-DedupVolume -ErrorAction SilentlyContinue);if($vs.Count -eq 0){& $Context.NewFinding 'StorageInternals' 'Data Deduplication' 'NoData' 'No deduplication volumes returned.' 'No action required.' $null}else{foreach($v in $vs){& $Context.NewFinding 'StorageInternals' $v.Volume 'Info' ("Enabled={0}; SavedSpace={1}; SavingsRate={2}" -f $v.Enabled,$v.SavedSpace,$v.SavingsRate) 'Manage deduplication only through supported storage tooling.' $null}}}
    }
}
