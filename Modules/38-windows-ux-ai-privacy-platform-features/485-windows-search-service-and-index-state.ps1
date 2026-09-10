# WinScope 11 native module
[pscustomobject]@{
    Id                = 485
    Name              = 'Windows Search Service and Index State'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows Search service and common index database footprint.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'WindowsUX' @('WSearch') 'Windows Search may be delayed/trigger started depending on Windows configuration.'
        $db=Join-Path $env:ProgramData 'Microsoft\Search\Data\Applications\Windows\Windows.db'
        if(Test-Path -LiteralPath $db) {
            $f=Get-Item -LiteralPath $db -ErrorAction SilentlyContinue
            & $Context.NewFinding 'WindowsUX' 'Windows Search database' 'Info' ("Path={0}; LastWrite={1}" -f $f.FullName,$f.LastWriteTime) 'Large index files may be normal; rebuild only through supported Search settings/troubleshooting.' ([long]$f.Length)
        } else {
            & $Context.NewFinding 'WindowsUX' 'Windows Search database' 'NotFound' 'Common Windows.db path was not found.' 'Index location can vary by Windows build/configuration.' $null
        }
    }
}
