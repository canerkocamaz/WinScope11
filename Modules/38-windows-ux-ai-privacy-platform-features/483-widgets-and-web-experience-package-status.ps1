# WinScope 11 native module
[pscustomobject]@{
    Id                = 483
    Name              = 'Widgets and Web Experience Package Status'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports the Windows Web Experience Pack used by Widgets and web-backed shell experiences.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $pkgs=@(Get-AppxPackage -Name 'MicrosoftWindows.Client.WebExperience' -ErrorAction SilentlyContinue)
            if($pkgs.Count -eq 0) {
                & $Context.NewFinding 'WindowsUX' 'Web Experience Pack' 'NotFound' 'MicrosoftWindows.Client.WebExperience package was not returned.' 'Package availability varies by Windows build and feature configuration.' $null
            } else {
                foreach($p in $pkgs) {
                    & $Context.NewFinding 'WindowsUX' $p.Name ([string]$p.Status) ("Version={0}; Publisher={1}; InstallLocation={2}" -f $p.Version,$p.Publisher,$p.InstallLocation) 'Web Experience package state is informational; use supported Windows servicing mechanisms for repair.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'WindowsUX' 'Web Experience Pack' 'Unavailable' $_.Exception.Message 'Appx inventory failed.' $null
        }
    }
}
