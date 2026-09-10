# WinScope 11 native module
[pscustomobject]@{
    Id                = 429
    Name              = 'Unquoted Service Path Analyzer'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Finds service executable paths containing spaces that are not quoted.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.PathName})
            $found=0
            foreach($s in $svcs) {
                $p=[string]$s.PathName
                if($p -match '^[A-Za-z]:\\' -and $p -match '\s' -and -not $p.TrimStart().StartsWith('"')) {
                    $found++
                    & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Warning' ("Name={0}; PathName={1}; StartName={2}" -f $s.Name,$p,$s.StartName) 'An unquoted service path with writable intermediate directories can create privilege-escalation risk. Validate ACLs and vendor configuration before remediation.' $null
                }
            }
            if($found -eq 0) {
                & $Context.NewFinding 'ServiceDeep' 'Unquoted service paths' 'Healthy' 'No obvious unquoted absolute service paths with spaces were found.' 'No action required based on this check.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Unquoted service paths' 'Unavailable' $_.Exception.Message 'CIM service inventory failed.' $null
        }
    }
}
