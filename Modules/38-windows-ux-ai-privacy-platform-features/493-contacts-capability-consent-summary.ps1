# WinScope 11 native module
[pscustomobject]@{
    Id                = 493
    Name              = 'Contacts Capability Consent Summary'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports top-level current-user contacts capability consent metadata.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path='HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts'
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'Privacy' 'Contacts capability' 'NotConfigured' ("ConsentStore path not present: {0}" -f $path) 'Per-app capability consent can also exist in child keys and Windows Settings.' $null
        } else {
            $p=Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
            $value=''
            $start=''
            $stop=''
            if($p) {
                if($p.PSObject.Properties.Name -contains 'Value'){$value=[string]$p.Value}
                if($p.PSObject.Properties.Name -contains 'LastUsedTimeStart'){$start=[string]$p.LastUsedTimeStart}
                if($p.PSObject.Properties.Name -contains 'LastUsedTimeStop'){$stop=[string]$p.LastUsedTimeStop}
            }
            & $Context.NewFinding 'Privacy' 'Contacts capability' 'Info' ("Value={0}; LastUsedStart={1}; LastUsedStop={2}" -f $value,$start,$stop) 'This is top-level consent metadata only; per-application child keys are not modified.' $null
        }
    }
}
