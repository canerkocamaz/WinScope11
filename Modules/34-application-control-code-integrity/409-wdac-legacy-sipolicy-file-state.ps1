# WinScope 11 native module
[pscustomobject]@{
    Id                = 409
    Name              = 'WDAC Legacy SIPolicy File State'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports the legacy SIPolicy.p7b Code Integrity policy file when present.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path=Join-Path $env:WINDIR 'System32\CodeIntegrity\SIPolicy.p7b'
        if(Test-Path -LiteralPath $path) {
            $f=Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
            & $Context.NewFinding 'CodeIntegrity' 'SIPolicy.p7b' 'Present' ("Path={0}; LastWrite={1}" -f $f.FullName,$f.LastWriteTime) 'Legacy WDAC policy files are report-only and should be managed with supported WDAC tooling.' ([long]$f.Length)
        } else {
            & $Context.NewFinding 'CodeIntegrity' 'SIPolicy.p7b' 'NotFound' 'Legacy SIPolicy.p7b was not found.' 'Modern multiple-policy WDAC deployments may use CiPolicies instead.' $null
        }
    }
}
