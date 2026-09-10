# WinScope 11 native module
[pscustomobject]@{
    Id                = 356
    Name              = 'Windows Update DataStore Footprint'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports SoftwareDistribution DataStore footprint.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $p=(Join-Path $env:WINDIR 'SoftwareDistribution\DataStore')
        & $Context.FolderFootprint 'WindowsUpdateDeep' 'Windows Update DataStore' $p 'DataStore is Windows-managed and must not be manually deleted based only on size.'
    }
}
