# WinScope 11 native module
[pscustomobject]@{
    Id                = 427
    Name              = 'Svchost Group Configuration'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports service-host groups from the Svchost registry configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost'
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'ServiceDeep' 'Svchost groups' 'NotFound' 'Svchost registry path was not found.' 'This is unexpected on a normal Windows installation.' $null
        } else {
            $p=Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
            foreach($prop in @($p.PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'})) {
                $value=if($prop.Value -is [array]){$prop.Value -join ','}else{[string]$prop.Value}
                & $Context.NewFinding 'ServiceDeep' $prop.Name 'Info' ("Members={0}" -f $value) 'Svchost groups are Windows service-host configuration; report-only.' $null
            }
        }
    }
}
