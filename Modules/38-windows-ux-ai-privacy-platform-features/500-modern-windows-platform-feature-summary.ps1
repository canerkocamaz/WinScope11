# WinScope 11 native module
[pscustomobject]@{
    Id                = 500
    Name              = 'Modern Windows Platform Feature Summary'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Summarizes selected Windows optional platform features such as Hyper-V, WSL, Sandbox, Virtual Machine Platform, Containers, and Hypervisor Platform.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $features=@(
            'Microsoft-Hyper-V-All',
            'Microsoft-Windows-Subsystem-Linux',
            'VirtualMachinePlatform',
            'Containers-DisposableClientVM',
            'Containers',
            'HypervisorPlatform',
            'Microsoft-Windows-Sandbox'
        )

        $cmd=Get-Command Get-WindowsOptionalFeature -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'WindowsPlatform' 'Optional platform features' 'Unavailable' 'Get-WindowsOptionalFeature is unavailable.' 'DISM/Windows optional feature tooling may be unavailable in this environment.' $null
        } else {
            foreach($name in $features) {
                try {
                    $f=Get-WindowsOptionalFeature -Online -FeatureName $name -ErrorAction Stop
                    & $Context.NewFinding 'WindowsPlatform' $name ([string]$f.State) ("RestartRequired={0}; CustomProperties={1}" -f $f.RestartRequired,($f.CustomProperties -join ';')) 'Platform features can be required by development, security, containers, WSL, Sandbox, or virtualization workloads; report-only.' $null
                } catch {
                    & $Context.NewFinding 'WindowsPlatform' $name 'NotAvailable' $_.Exception.Message 'Feature names/availability vary by Windows edition and build.' $null
                }
            }
        }

        try {
            $cs=Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
            & $Context.NewFinding 'WindowsPlatform' 'Hypervisor presence' 'Info' ("HypervisorPresent={0}; Model={1}" -f $cs.HypervisorPresent,$cs.Model) 'Use this together with feature-state and VBS modules for overall platform posture.' $null
        } catch {}
    }
}
