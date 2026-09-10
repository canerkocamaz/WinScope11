# WinScope 11 native module
[pscustomobject]@{
    Id                = 411
    Name              = 'Device Guard Code Integrity Enforcement State'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports kernel/user-mode Code Integrity policy enforcement status from Win32_DeviceGuard.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $dg=Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction Stop
            & $Context.NewFinding 'CodeIntegrity' 'Device Guard enforcement' 'Info' ("KMCI={0}; UMCI={1}; VBS={2}; Configured={3}; Running={4}" -f $dg.CodeIntegrityPolicyEnforcementStatus,$dg.UsermodeCodeIntegrityPolicyEnforcementStatus,$dg.VirtualizationBasedSecurityStatus,($dg.SecurityServicesConfigured -join ','),($dg.SecurityServicesRunning -join ',')) 'Interpret enforcement values with WDAC/AppLocker policy and Windows build documentation.' $null
        } catch {
            & $Context.NewFinding 'CodeIntegrity' 'Device Guard enforcement' 'Unavailable' $_.Exception.Message 'Win32_DeviceGuard may be unavailable on some editions or builds.' $null
        }
    }
}
