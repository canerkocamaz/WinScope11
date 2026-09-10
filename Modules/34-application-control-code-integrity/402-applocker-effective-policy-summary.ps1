# WinScope 11 native module
[pscustomobject]@{
    Id                = 402
    Name              = 'AppLocker Effective Policy Summary'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports the effective AppLocker policy in XML form when AppLocker cmdlets are available.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-AppLockerPolicy -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'ApplicationControl' 'Effective AppLocker policy' 'Unavailable' 'Get-AppLockerPolicy is unavailable on this Windows edition/environment.' 'AppLocker availability depends on Windows edition and policy configuration.' $null
        } else {
            try {
                $xml=(Get-AppLockerPolicy -Effective -Xml -ErrorAction Stop | Out-String).Trim()
                if([string]::IsNullOrWhiteSpace($xml)){$xml='No effective policy XML was returned.'}
                & $Context.NewFinding 'ApplicationControl' 'Effective AppLocker policy' 'Info' $xml 'AppLocker policy is report-only; validate business requirements before any rule changes.' $null
            } catch {
                & $Context.NewFinding 'ApplicationControl' 'Effective AppLocker policy' 'Unavailable' $_.Exception.Message 'AppLocker policy retrieval may require an applicable Windows edition and permissions.' $null
            }
        }
    }
}
