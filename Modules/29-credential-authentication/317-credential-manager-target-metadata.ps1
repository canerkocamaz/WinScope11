# WinScope 11 native module
[pscustomobject]@{
    Id                = 317
    Name              = 'Credential Manager Safe Audit'
    Group             = 'Credential & Authentication'
    GroupId           = 29
    Flags             = '[R][N]'
    Description       = 'Reports Credential Manager service posture without enumerating credential targets.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)

        & $Context.ServiceSnapshot `
            'Authentication' `
            @('VaultSvc') `
            'Credential Manager service state is reported without enumerating stored credential targets or secret material.'

        & $Context.NewFinding `
            'Authentication' `
            'Credential target enumeration' `
            'SkippedBySafeAuditPolicy' `
            'Safe Audit Edition does not enumerate Credential Manager target metadata.' `
            'Use approved administrative tooling when credential-target inventory is explicitly required.' `
            $null
    }
}
