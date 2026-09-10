# WinScope 11 native module
[pscustomobject]@{
    Id                = 338
    Name              = 'Current User RSA Key Store Footprint'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports aggregate size/count of current-user RSA key-container files without opening keys.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $root = Join-Path $env:APPDATA 'Microsoft\Crypto\RSA'
        if(-not (Test-Path -LiteralPath $root)) {
            & $Context.NewFinding 'Crypto' 'Current user RSA key store' 'NotFound' ("Path not present: {0}" -f $root) 'Only aggregate footprint is reported; key contents are never read.' $null
        } else {
            $files=@(Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue)
            $sum=($files|Measure-Object Length -Sum).Sum
            if($null -eq $sum){$sum=0}
            & $Context.NewFinding 'Crypto' 'Current user RSA key store' 'Info' ("Key container files={0}; Path={1}" -f $files.Count,$root) 'Only aggregate footprint is reported; key contents are never read.' ([long]$sum)
        }
    }
}
