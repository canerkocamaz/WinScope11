# WinScope 11 native module
[pscustomobject]@{
    Id                = 430
    Name              = 'Third-Party Service Binary Signature Review'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Checks Authenticode signature status for a bounded sample of third-party service executables.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $windows=[IO.Path]::GetFullPath($env:WINDIR).TrimEnd('\')
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.PathName} | Sort-Object Name)
            $checked=0
            foreach($s in $svcs) {
                if($checked -ge 100){break}
                $raw=[Environment]::ExpandEnvironmentVariables([string]$s.PathName).Trim()
                $exe=$null
                if($raw.StartsWith('"')) {
                    $m=[regex]::Match($raw,'^"([^"]+)"')
                    if($m.Success){$exe=$m.Groups[1].Value}
                } else {
                    $m=[regex]::Match($raw,'^(.+?\.exe)(?:\s|$)','IgnoreCase')
                    if($m.Success){$exe=$m.Groups[1].Value}
                }
                if(-not $exe -or -not (Test-Path -LiteralPath $exe -PathType Leaf)){continue}
                $full=[IO.Path]::GetFullPath($exe)
                if($full.StartsWith($windows,[StringComparison]::OrdinalIgnoreCase)){continue}
                $checked++
                $sig=Get-AuthenticodeSignature -LiteralPath $full -ErrorAction SilentlyContinue
                $status=if($null -eq $sig){'Unavailable'}else{[string]$sig.Status}
                & $Context.NewFinding 'ServiceDeep' $s.DisplayName $status ("Binary={0}; Signer={1}" -f $full,$sig.SignerCertificate.Subject) 'Unsigned or invalid third-party service binaries deserve vendor/provenance review; do not remove solely based on signature state.' $null
            }
            if($checked -eq 0) {
                & $Context.NewFinding 'ServiceDeep' 'Third-party service signatures' 'NoData' 'No eligible third-party service binaries were checked.' 'No action required.' $null
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Third-party service signatures' 'Unavailable' $_.Exception.Message 'Service binary signature review failed.' $null
        }
    }
}
