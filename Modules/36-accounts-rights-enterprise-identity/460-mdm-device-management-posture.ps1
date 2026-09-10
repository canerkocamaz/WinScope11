# WinScope 11 native module
[pscustomobject]@{
    Id                = 460
    Name              = 'MDM Device Management Posture'
    Group             = 'Accounts, Rights & Enterprise Identity'
    GroupId           = 36
    Flags             = '[R][N]'
    Description       = 'Reports Windows device-management service and policy posture without enumerating enrollment identifiers or scheduled tasks.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)

        & $Context.ServiceSnapshot `
            'EnterpriseIdentity' `
            @('dmwappushservice') `
            'The Device Management WAP Push service can support MDM communication and may be demand-started.'

        $policyRoot='HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device'
        if(Test-Path -LiteralPath $policyRoot) {
            $subkeys=@(Get-ChildItem -LiteralPath $policyRoot -ErrorAction SilentlyContinue | Select-Object -First 40)
            & $Context.NewFinding `
                'EnterpriseIdentity' `
                'PolicyManager device policy root' `
                'Present' `
                ("TopLevelPolicyAreas={0}; Path={1}" -f $subkeys.Count,$policyRoot) `
                'PolicyManager presence indicates locally available device-policy state; WinScope does not enumerate enrollment identifiers or modify policy.' `
                $null
        } else {
            & $Context.NewFinding `
                'EnterpriseIdentity' `
                'PolicyManager device policy root' `
                'NotFound' `
                ("Path not present: {0}" -f $policyRoot) `
                'This can be normal on unmanaged or minimally managed devices.' `
                $null
        }

        $workplace='HKCU:\Software\Microsoft\WorkplaceJoin'
        if(Test-Path -LiteralPath $workplace) {
            & $Context.NewFinding `
                'EnterpriseIdentity' `
                'Current-user Workplace Join registry area' `
                'Present' `
                ("Path={0}" -f $workplace) `
                'Presence is informational only; no enrollment IDs, tokens, certificates, or secrets are read.' `
                $null
        } else {
            & $Context.NewFinding `
                'EnterpriseIdentity' `
                'Current-user Workplace Join registry area' `
                'NotFound' `
                'No current-user WorkplaceJoin registry area was found.' `
                'This can be normal when workplace registration is not used.' `
                $null
        }
    }
}
