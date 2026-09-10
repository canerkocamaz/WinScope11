# WinScope 11 native module
[pscustomobject]@{
    Id                = 379
    Name              = 'System Guard Policy Snapshot'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports selected Device Guard/System Guard policy registry values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'FirmwareSecurity' 'Device Guard policy' 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard' @('EnableVirtualizationBasedSecurity','RequirePlatformSecurityFeatures','HypervisorEnforcedCodeIntegrity') 'Device Guard settings can be policy-managed and should be changed only through supported controls.'
    }
}
