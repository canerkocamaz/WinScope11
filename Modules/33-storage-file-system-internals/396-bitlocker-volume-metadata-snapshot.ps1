# WinScope 11 native module
[pscustomobject]@{
    Id                = 396
    Name              = 'BitLocker Volume Metadata Snapshot'
    Group             = 'Storage & File-System Internals'
    GroupId           = 33
    Flags             = '[R][N]'
    Description       = 'Reports BitLocker state without exposing recovery passwords.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {foreach($v in @(Get-BitLockerVolume -ErrorAction Stop)){& $Context.NewFinding 'StorageInternals' $v.MountPoint ([string]$v.ProtectionStatus) ("VolumeStatus={0}; Encryption={1}; Percent={2}; Lock={3}; AutoUnlock={4}; Protectors={5}" -f $v.VolumeStatus,$v.EncryptionMethod,$v.EncryptionPercentage,$v.LockStatus,$v.AutoUnlockEnabled,@($v.KeyProtector).Count) 'WinScope never exposes recovery passwords or key material.' $null}}catch{& $Context.NewFinding 'StorageInternals' 'BitLocker' 'Unavailable' $_.Exception.Message 'BitLocker cmdlets may require a supported edition/elevation.' $null}
    }
}
