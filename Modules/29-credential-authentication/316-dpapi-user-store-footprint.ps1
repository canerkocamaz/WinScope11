# WinScope 11 native module
[pscustomobject]@{
    Id                = 316
    Name              = 'DPAPI User Store Footprint'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports only the aggregate count and size of the current user''s DPAPI protection store.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root = Join-Path $env:APPDATA 'Microsoft\Protect'
        if(-not (Test-Path -LiteralPath $root)) {
            & $Context.NewFinding 'Authentication' 'DPAPI user protection store' 'NotFound' ("Path not present: {0}" -f $root) 'DPAPI storage is reported by aggregate footprint only; secret material is never read.' $null
        } else {
            $files = @(Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue)
            $sum = ($files | Measure-Object Length -Sum).Sum
            if($null -eq $sum){$sum=0}
            & $Context.NewFinding 'Authentication' 'DPAPI user protection store' 'Info' ("Files={0}; Path={1}" -f $files.Count,$root) 'DPAPI storage is reported by aggregate footprint only; secret material is never read.' ([long]$sum)
        }
    }
}
