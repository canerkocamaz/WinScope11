# WinScope 11 native module
[pscustomobject]@{
    Id                = 357
    Name              = 'Catroot2 Footprint'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports Windows catroot2 footprint.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $p=(Join-Path $env:WINDIR 'System32\catroot2')
        & $Context.FolderFootprint 'WindowsUpdateDeep' 'catroot2' $p 'catroot2 contains catalog/servicing state; report-only.'
    }
}
