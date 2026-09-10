# WinScope 11 native module
[pscustomobject]@{
    Id                = 344
    Name              = 'SoftwareDistribution Total Footprint'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports total SoftwareDistribution folder footprint.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path = (Join-Path $env:WINDIR 'SoftwareDistribution')
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'WindowsUpdateDeep' 'SoftwareDistribution' 'NotFound' ("Path not present: {0}" -f $path) 'SoftwareDistribution is Windows-managed; manual deletion can disrupt update state.' $null
        } else {
            $files=@(Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue)
            $sum=($files|Measure-Object Length -Sum).Sum
            if($null -eq $sum){$sum=0}
            & $Context.NewFinding 'WindowsUpdateDeep' 'SoftwareDistribution' 'Info' ("Files={0}; Path={1}" -f $files.Count,$path) 'SoftwareDistribution is Windows-managed; manual deletion can disrupt update state.' ([long]$sum)
        }
    }
}
