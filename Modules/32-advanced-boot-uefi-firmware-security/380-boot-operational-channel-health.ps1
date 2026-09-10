# WinScope 11 native module
[pscustomobject]@{
    Id                = 380
    Name              = 'Boot Operational Channel Health'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports Kernel-Boot Operational channel configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$l=Get-WinEvent -ListLog 'Microsoft-Windows-Kernel-Boot/Operational' -ErrorAction Stop;& $Context.NewFinding 'Boot' 'Kernel-Boot/Operational' $(if($l.IsEnabled){'Enabled'}else{'Disabled'}) ("RecordCount={0}; MaxSize={1}; Mode={2}" -f $l.RecordCount,$l.MaximumSizeInBytes,$l.LogMode) 'WinScope does not change event-channel state.' ([long]$l.FileSize)}catch{& $Context.NewFinding 'Boot' 'Kernel-Boot/Operational' 'Unavailable' $_.Exception.Message 'Channel may not exist on this build.' $null}
    }
}
