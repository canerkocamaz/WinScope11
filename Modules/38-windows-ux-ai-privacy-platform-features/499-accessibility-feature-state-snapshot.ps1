# WinScope 11 native module
[pscustomobject]@{
    Id                = 499
    Name              = 'Accessibility Feature State Snapshot'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports selected current-user accessibility settings without changing them.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $checks=@(
            @{Name='StickyKeys';Path='HKCU:\Control Panel\Accessibility\StickyKeys';Names=@('Flags')},
            @{Name='Keyboard Response';Path='HKCU:\Control Panel\Accessibility\Keyboard Response';Names=@('Flags','AutoRepeatDelay','AutoRepeatRate')},
            @{Name='ToggleKeys';Path='HKCU:\Control Panel\Accessibility\ToggleKeys';Names=@('Flags')},
            @{Name='HighContrast';Path='HKCU:\Control Panel\Accessibility\HighContrast';Names=@('Flags','High Contrast Scheme')},
            @{Name='Narrator';Path='HKCU:\Software\Microsoft\Narrator';Names=@('NarratorCursorHighlight','CoupleNarratorCursorKeyboard')}
        )
        foreach($c in $checks) {
            & $Context.RegistrySnapshot 'WindowsUX' $c.Name $c.Path $c.Names 'Accessibility settings are user-specific and should never be reset merely because they differ from defaults.'
        }
    }
}
