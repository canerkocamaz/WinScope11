# WinScope 11 native module
[pscustomobject]@{
    Id                = 345
    Name              = 'Catroot2 Footprint'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports Windows catroot2 footprint.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path = (Join-Path $env:WINDIR 'System32\catroot2')
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'WindowsUpdateDeep' 'catroot2' 'NotFound' ("Path not present: {0}" -f $path) 'catroot2 contains servicing/catalog state and should not be manually cleaned based only on size.' $null
        } else {
            $files=@(Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue)
            $sum=($files|Measure-Object Length -Sum).Sum
            if($null -eq $sum){$sum=0}
            & $Context.NewFinding 'WindowsUpdateDeep' 'catroot2' 'Info' ("Files={0}; Path={1}" -f $files.Count,$path) 'catroot2 contains servicing/catalog state and should not be manually cleaned based only on size.' ([long]$sum)
        }
    }
}
