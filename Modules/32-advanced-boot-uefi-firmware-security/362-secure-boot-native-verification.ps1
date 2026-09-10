# WinScope 11 native module
[pscustomobject]@{
    Id                = 362
    Name              = 'Secure Boot Native Verification'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Verifies Secure Boot state with Confirm-SecureBootUEFI.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$e=Confirm-SecureBootUEFI -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'Secure Boot' $(if($e){'Enabled'}else{'Disabled'}) ("Enabled={0}" -f $e) 'Secure Boot protects the boot chain when supported.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'Secure Boot' 'Unavailable' $_.Exception.Message 'Secure Boot may require UEFI and elevated access.' $null}
    }
}
