# WinScope 11 native module template
[pscustomobject]@{
    Id                = 501
    Name              = 'Example Native Module'
    Group             = 'Future Extensions'
    GroupId           = 39
    Flags             = '[R][N]'
    Description       = 'Template for a fully native WinScope module.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true

    Invoke = {
        param($Context)

        # Return one or more standardized records:
        & $Context.NewFinding `
            'ExampleCategory' `
            'Example item' `
            'Info' `
            'Technical details.' `
            'Recommendation for the operator.' `
            $null
    }
}
