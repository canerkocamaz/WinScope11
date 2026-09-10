# WinScope 11 native module
[pscustomobject]@{
    Id                = 408
    Name              = 'WDAC Active Policy File Inventory'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports Windows Defender Application Control policy files in the active Code Integrity policy directory.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path=Join-Path $env:WINDIR 'System32\CodeIntegrity\CiPolicies\Active'
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'CodeIntegrity' 'WDAC active policies' 'NotFound' ("Path not present: {0}" -f $path) 'WDAC policy layout varies by Windows build and deployment method.' $null
        } else {
            $files=@(Get-ChildItem -LiteralPath $path -File -Force -ErrorAction SilentlyContinue)
            if($files.Count -eq 0) {
                & $Context.NewFinding 'CodeIntegrity' 'WDAC active policies' 'NoData' 'No files were present in the active policy directory.' 'Policy state should also be correlated with Code Integrity events and Device Guard state.' $null
            } else {
                foreach($f in $files) {
                    & $Context.NewFinding 'CodeIntegrity' $f.Name 'Info' ("Path={0}; LastWrite={1}" -f $f.FullName,$f.LastWriteTime) 'WDAC policy files are security-sensitive and must not be manually deleted.' ([long]$f.Length)
                }
            }
        }
    }
}
