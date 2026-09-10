# WinScope 11 native module
[pscustomobject]@{
    Id                = 343
    Name              = 'Windows Update DataStore Footprint'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports the SoftwareDistribution DataStore footprint without opening or modifying the database.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $path = (Join-Path $env:WINDIR 'SoftwareDistribution\DataStore')
        if(-not (Test-Path -LiteralPath $path)) {
            & $Context.NewFinding 'WindowsUpdateDeep' 'Windows Update DataStore' 'NotFound' ("Path not present: {0}" -f $path) 'DataStore is Windows-managed. Do not manually delete it based only on size.' $null
        } else {
            $files=@(Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue)
            $sum=($files|Measure-Object Length -Sum).Sum
            if($null -eq $sum){$sum=0}
            & $Context.NewFinding 'WindowsUpdateDeep' 'Windows Update DataStore' 'Info' ("Files={0}; Path={1}" -f $files.Count,$path) 'DataStore is Windows-managed. Do not manually delete it based only on size.' ([long]$sum)
        }
    }
}
