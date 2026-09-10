# WinScope 11 native module
[pscustomobject]@{
    Id                = 406
    Name              = 'AppLocker DLL Rules'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports effective AppLocker Dll rules.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $cmd=Get-Command Get-AppLockerPolicy -ErrorAction SilentlyContinue
        if($null -eq $cmd) {
            & $Context.NewFinding 'ApplicationControl' 'Dll rules' 'Unavailable' 'Get-AppLockerPolicy is unavailable.' 'AppLocker availability depends on Windows edition.' $null
        } else {
            try {
                $policy=Get-AppLockerPolicy -Effective -ErrorAction Stop
                $collection=$policy.RuleCollections | Where-Object CollectionType -eq 'Dll'
                $rules=@($collection.Rules)
                if($rules.Count -eq 0) {
                    & $Context.NewFinding 'ApplicationControl' 'Dll rules' 'NoData' 'No effective rules were returned for this collection.' 'Absence of rules should be interpreted together with collection enforcement mode.' $null
                } else {
                    foreach($r in $rules) {
                        & $Context.NewFinding 'ApplicationControl' $r.Name 'Info' ("Id={0}; Action={1}; UserOrGroupSid={2}" -f $r.Id,$r.Action,$r.UserOrGroupSid) 'AppLocker rule inventory is report-only.' $null
                    }
                }
            } catch {
                & $Context.NewFinding 'ApplicationControl' 'Dll rules' 'Unavailable' $_.Exception.Message 'Unable to read effective AppLocker policy.' $null
            }
        }
    }
}
