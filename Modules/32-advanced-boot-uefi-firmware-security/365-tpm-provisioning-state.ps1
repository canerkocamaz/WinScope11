# WinScope 11 native module
[pscustomobject]@{
    Id                = 365
    Name              = 'TPM Provisioning State'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports TPM readiness and provisioning state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$t=Get-Tpm -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'TPM' $(if($t.TpmReady){'Ready'}else{'Review'}) ("Present={0}; Ready={1}; Enabled={2}; Activated={3}; Owned={4}; AutoProvisioning={5}" -f $t.TpmPresent,$t.TpmReady,$t.TpmEnabled,$t.TpmActivated,$t.TpmOwned,$t.AutoProvisioning) 'WinScope never clears or initializes the TPM.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'TPM' 'Unavailable' $_.Exception.Message 'TPM cmdlets may require elevated access.' $null}
    }
}
