# WinScope 11 native module
[pscustomobject]@{
    Id                = 314
    Name              = 'Secondary Logon Service Health'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports Secondary Logon service state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($name in @('seclogon')) {
            $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
            if($null -eq $svc) {
                & $Context.NewFinding 'Authentication' $name 'NotFound' 'Service is not installed or not available in this Windows edition.' 'Secondary Logon supports alternate-credential process launch and can be policy-dependent.' $null
            } else {
                $start = ''
                try {
                    $c = Get-CimInstance Win32_Service -Filter ("Name='{0}'" -f $name) -ErrorAction Stop
                    $start = [string]$c.StartMode
                } catch {}
                & $Context.NewFinding 'Authentication' $svc.DisplayName ([string]$svc.Status) ("Name={0}; StartMode={1}" -f $name,$start) 'Secondary Logon supports alternate-credential process launch and can be policy-dependent.' $null
            }
        }
    }
}
