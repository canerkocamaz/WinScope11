# WinScope 11 native module
[pscustomobject]@{
    Id                = 410
    Name              = 'Code Integrity Operational Error Summary'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports recent Code Integrity Operational errors and warnings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'CodeIntegrity' 'Code Integrity Operational' 'Microsoft-Windows-CodeIntegrity/Operational' 30 80 '' 'Recurring Code Integrity failures can reveal blocked or invalid code, drivers, or application-control policy conflicts.' -ErrorsOnly
    }
}
