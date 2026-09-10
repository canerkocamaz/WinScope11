Set-StrictMode -Version Latest

function Test-WSAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Write-WSLogo {
    Write-Host ' __        ___       ____                       _ _ ' -ForegroundColor Green
    Write-Host ' \ \      / (_)_ __ / ___|  ___ ___  _ __   __| | |' -ForegroundColor Green
    Write-Host '  \ \ /\ / /| | ''_ \\___ \ / __/ _ \| ''_ \ / _` | |' -ForegroundColor Green
    Write-Host '   \ V  V / | | | | |___) | (_| (_) | |_) | (_| | |' -ForegroundColor Green
    Write-Host '    \_/\_/  |_|_| |_|____/ \___\___/| .__/ \__,_|_|' -ForegroundColor Green
    Write-Host '                                    |_|' -ForegroundColor Green
}

function Write-WSHeader {
    param(
        [int]$ModuleCount,
        [int]$GroupCount,
        [string]$Subtitle = 'Windows Client Health, Security & Configuration Analyzer'
    )

    Clear-Host
    Write-WSLogo
    Write-Host ''
    Write-Host ' WinScope 11' -ForegroundColor White
    Write-Host (" {0}" -f $Subtitle) -ForegroundColor DarkGray
    Write-Host ''
    Write-Host (" Host: {0}   User: {1}   Admin: {2}   PowerShell: {3}" -f `
        $env:COMPUTERNAME,
        $env:USERNAME,
        ($(if(Test-WSAdmin){'YES'}else{'NO'})),
        $PSVersionTable.PSVersion) -ForegroundColor Gray
    Write-Host (" Modules: {0}   Main groups: {1}   Reporting: ON" -f `
        $ModuleCount,$GroupCount) -ForegroundColor DarkGray
    Write-Host ''
}

function Resolve-WSModuleIds {
    param(
        [Parameter(Mandatory)][string]$Expression,
        [Parameter(Mandatory)][object[]]$Modules
    )

    $valid = @{}
    foreach($m in $Modules) {
        $valid[[int]$m.Id] = $true
    }

    $resolved = New-Object 'System.Collections.Generic.HashSet[int]'
    [string[]]$invalid = @()

    $tokens = @(
        $Expression.Trim() -split '[,;\s]+' |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )

    foreach($token in $tokens) {
        if($token -match '^(\d+)-(\d+)$') {
            $start = [int]$Matches[1]
            $end   = [int]$Matches[2]

            if($start -gt $end) {
                $tmp=$start; $start=$end; $end=$tmp
            }

            foreach($n in $start..$end) {
                if($valid.ContainsKey($n)) {
                    [void]$resolved.Add($n)
                } else {
                    $invalid += [string]$n
                }
            }
            continue
        }

        $n = 0
        if([int]::TryParse($token,[ref]$n) -and $valid.ContainsKey($n)) {
            [void]$resolved.Add($n)
        } else {
            $invalid += $token
        }
    }

    return [pscustomobject]@{
        Ids     = @($resolved | Sort-Object)
        Invalid = [string[]]$invalid
    }
}

function Show-WSCompactModuleList {
    param([Parameter(Mandatory)][object[]]$Modules)

    $rows = @(
        $Modules |
            Sort-Object Id |
            Select-Object `
                @{N='ID';E={"{0:D3}" -f [int]$_.Id}},
                @{N='Subgroup';E={$_.SubGroupCode}},
                @{N='Leaf';E={$_.LeafGroupCode}},
                @{N='Module';E={$_.Name}}
    )

    if($rows.Count -eq 0) {
        Write-Host ' No modules found.' -ForegroundColor Yellow
        return
    }

    $rows | Format-Table -AutoSize | Out-Host -Paging
}

function Show-WSMainGroupSummary {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][object[]]$Groups
    )

    $ordered = @($Groups | Sort-Object Id)

    Write-Host ' Main Groups' -ForegroundColor White
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray
    for($i=0; $i -lt $ordered.Count; $i++) {
        $g = $ordered[$i]
        Write-Host ("  {0,2}. {1,-47} ({2,3} modules)" -f `
            ($i+1),$g.Name,$g.ModuleCount) -ForegroundColor Gray
    }
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray

    return $ordered
}

function Show-WSSubGroupSummary {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$MainCode
    )

    $subs = @(Get-WSSubGroupCatalog -Modules $Modules -MainGroupCode $MainCode)

    Write-Host ' Subgroups' -ForegroundColor White
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray
    for($i=0; $i -lt $subs.Count; $i++) {
        $s = $subs[$i]
        Write-Host ("  {0,2}. {1,-47} ({2,3} modules)" -f `
            ($i+1),$s.Name,$s.ModuleCount) -ForegroundColor Gray
    }
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray

    return $subs
}

function Show-WSLeafGroupSummary {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$SubCode
    )

    $leafs = @(Get-WSLeafGroupCatalog -Modules $Modules -SubGroupCode $SubCode)

    Write-Host ' Categories' -ForegroundColor White
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray
    for($i=0; $i -lt $leafs.Count; $i++) {
        $l = $leafs[$i]
        Write-Host ("  {0,2}. {1,-47} ({2,3} modules)" -f `
            ($i+1),$l.Name,$l.ModuleCount) -ForegroundColor Gray
    }
    Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray

    return $leafs
}

function Confirm-WSModuleSelection {
    param(
        [Parameter(Mandatory)][int[]]$Ids,
        [Parameter(Mandatory)][object[]]$Modules
    )

    $selected = @(
        foreach($id in $Ids) {
            $Modules | Where-Object Id -eq $id | Select-Object -First 1
        }
    )

    Write-Host ''
    Write-Host (" Selected module(s): {0}" -f ($Ids -join ', ')) -ForegroundColor Green
    foreach($m in $selected) {
        Write-Host ("   {0:D3}  {1}" -f [int]$m.Id,$m.Name) -ForegroundColor Gray
    }
    Write-Host ''

    $confirm = (Read-Host 'Press Enter to run, E to edit, or Q to cancel').Trim()
    if($confirm -match '^(?i:Q)$') { return 'Cancel' }
    if($confirm -match '^(?i:E)$') { return 'Edit' }
    return 'Run'
}

function Get-WSLocalMenuChoice {
    param(
        [Parameter(Mandatory)][string]$Raw,
        [Parameter(Mandatory)][object[]]$Items
    )

    $n = 0
    if(-not [int]::TryParse($Raw,[ref]$n)) {
        return $null
    }

    if($n -lt 1 -or $n -gt $Items.Count) {
        return $null
    }

    return $Items[$n-1]
}

function Select-WSModulesInteractive {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][object[]]$Groups
    )

    $mainCode = ''
    $mainName = ''
    $subCode  = ''
    $subName  = ''
    $leafCode = ''
    $leafName = ''

    while($true) {
        Write-WSHeader `
            -ModuleCount $Modules.Count `
            -GroupCount $Groups.Count `
            -Subtitle 'Module Selection'

        # --------------------------------------------------------------
        # LEVEL 1: main groups
        # --------------------------------------------------------------
        if(-not $mainCode) {
            $items = @(Show-WSMainGroupSummary -Modules $Modules -Groups $Groups)

            Write-Host ''
            Write-Host ' Choose a group by its LOCAL menu number.' -ForegroundColor White
            Write-Host ' Example: type 1, then press Enter.' -ForegroundColor DarkGray
            Write-Host ' A = all 500 modules | L = list all modules | Q = back' -ForegroundColor DarkGray
            Write-Host ''

            $raw = (Read-Host 'Group').Trim()

            if([string]::IsNullOrWhiteSpace($raw)) { continue }
            if($raw -match '^(?i:Q)$') { return @() }

            if($raw -match '^(?i:A)$') {
                $ids=@($Modules | Select-Object -ExpandProperty Id)
                $decision=Confirm-WSModuleSelection -Ids $ids -Modules $Modules
                if($decision -eq 'Run'){return $ids}
                if($decision -eq 'Cancel'){return @()}
                continue
            }

            if($raw -match '^(?i:L)$') {
                Show-WSCompactModuleList -Modules $Modules
                Read-Host 'Press Enter to return' | Out-Null
                continue
            }

            $choice = Get-WSLocalMenuChoice -Raw $raw -Items $items
            if($null -eq $choice) {
                Write-Host ' Invalid group number.' -ForegroundColor Yellow
                Read-Host 'Press Enter to continue' | Out-Null
                continue
            }

            $mainCode=[string]$choice.Code
            $mainName=[string]$choice.Name
            continue
        }

        # --------------------------------------------------------------
        # LEVEL 2: subgroups
        # --------------------------------------------------------------
        if(-not $subCode) {
            Write-Host (" Path: {0}" -f $mainName) -ForegroundColor Cyan
            Write-Host ''
            $items = @(Show-WSSubGroupSummary -Modules $Modules -MainCode $mainCode)

            Write-Host ''
            Write-Host ' Choose a subgroup by its LOCAL menu number.' -ForegroundColor White
            Write-Host ' A = run this whole main group | M = list its modules | B = back | Q = quit' -ForegroundColor DarkGray
            Write-Host ''

            $raw = (Read-Host 'Subgroup').Trim()

            if([string]::IsNullOrWhiteSpace($raw)) { continue }
            if($raw -match '^(?i:Q)$') { return @() }
            if($raw -match '^(?i:B)$') {
                $mainCode=''; $mainName=''
                continue
            }

            if($raw -match '^(?i:A)$') {
                $ids=@(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $mainCode | Select-Object -ExpandProperty Id)
                $decision=Confirm-WSModuleSelection -Ids $ids -Modules $Modules
                if($decision -eq 'Run'){return $ids}
                if($decision -eq 'Cancel'){return @()}
                continue
            }

            if($raw -match '^(?i:M)$') {
                $scope=@(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $mainCode)
                Show-WSCompactModuleList -Modules $scope
                Read-Host 'Press Enter to return' | Out-Null
                continue
            }

            $choice = Get-WSLocalMenuChoice -Raw $raw -Items $items
            if($null -eq $choice) {
                Write-Host ' Invalid subgroup number.' -ForegroundColor Yellow
                Read-Host 'Press Enter to continue' | Out-Null
                continue
            }

            $subCode=[string]$choice.Code
            $subName=[string]$choice.Name
            continue
        }

        # --------------------------------------------------------------
        # LEVEL 3: leaf categories
        # --------------------------------------------------------------
        if(-not $leafCode) {
            Write-Host (" Path: {0} > {1}" -f $mainName,$subName) -ForegroundColor Cyan
            Write-Host ''
            $items = @(Show-WSLeafGroupSummary -Modules $Modules -SubCode $subCode)

            # Some subgroups may contain just one leaf. Still show it as 1.
            Write-Host ''
            Write-Host ' Choose a category by its LOCAL menu number.' -ForegroundColor White
            Write-Host ' A = run this whole subgroup | M = list its modules | B = back | Q = quit' -ForegroundColor DarkGray
            Write-Host ''

            $raw = (Read-Host 'Category').Trim()

            if([string]::IsNullOrWhiteSpace($raw)) { continue }
            if($raw -match '^(?i:Q)$') { return @() }
            if($raw -match '^(?i:B)$') {
                $subCode=''; $subName=''
                continue
            }

            if($raw -match '^(?i:A)$') {
                $ids=@(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $subCode | Select-Object -ExpandProperty Id)
                $decision=Confirm-WSModuleSelection -Ids $ids -Modules $Modules
                if($decision -eq 'Run'){return $ids}
                if($decision -eq 'Cancel'){return @()}
                continue
            }

            if($raw -match '^(?i:M)$') {
                $scope=@(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $subCode)
                Show-WSCompactModuleList -Modules $scope
                Read-Host 'Press Enter to return' | Out-Null
                continue
            }

            $choice = Get-WSLocalMenuChoice -Raw $raw -Items $items
            if($null -eq $choice) {
                Write-Host ' Invalid category number.' -ForegroundColor Yellow
                Read-Host 'Press Enter to continue' | Out-Null
                continue
            }

            $leafCode=[string]$choice.Code
            $leafName=[string]$choice.Name
            continue
        }

        # --------------------------------------------------------------
        # LEVEL 4: modules; real module IDs are entered here.
        # --------------------------------------------------------------
        $leafModules = @(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $leafCode)

        Write-Host (" Path: {0} > {1} > {2}" -f $mainName,$subName,$leafName) -ForegroundColor Cyan
        Write-Host ''
        Write-Host ' Modules' -ForegroundColor White
        Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray
        foreach($m in $leafModules) {
            Write-Host ("  {0:D3}  {1}" -f [int]$m.Id,$m.Name) -ForegroundColor Gray
        }
        Write-Host ' ------------------------------------------------------------------------------' -ForegroundColor DarkGray
        Write-Host ''
        Write-Host ' Enter REAL module ID(s).' -ForegroundColor White
        Write-Host ' Examples: 36 | 36,41,460 | 36-40' -ForegroundColor DarkGray
        Write-Host ' A = run all modules in this category | B = back | Q = quit' -ForegroundColor DarkGray
        Write-Host ''

        $raw = (Read-Host 'Module ID(s)').Trim()

        if([string]::IsNullOrWhiteSpace($raw)) { continue }
        if($raw -match '^(?i:Q)$') { return @() }
        if($raw -match '^(?i:B)$') {
            $leafCode=''; $leafName=''
            continue
        }

        if($raw -match '^(?i:A)$') {
            $ids=@($leafModules | Select-Object -ExpandProperty Id)
            $decision=Confirm-WSModuleSelection -Ids $ids -Modules $Modules
            if($decision -eq 'Run'){return $ids}
            if($decision -eq 'Cancel'){return @()}
            continue
        }

        # At module level, validate against this leaf so an accidental ID from
        # another category cannot silently run.
        $parsed = Resolve-WSModuleIds -Expression $raw -Modules $leafModules

        if($parsed.Invalid.Count -gt 0) {
            Write-Host (" Invalid module ID(s) for this category: {0}" -f ($parsed.Invalid -join ', ')) -ForegroundColor Yellow
        }

        if($parsed.Ids.Count -eq 0) {
            Read-Host 'Press Enter to continue' | Out-Null
            continue
        }

        $decision = Confirm-WSModuleSelection -Ids @($parsed.Ids) -Modules $Modules
        if($decision -eq 'Run'){return @($parsed.Ids)}
        if($decision -eq 'Cancel'){return @()}
    }
}

function Write-WSRunProgress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$ModuleName,
        [string]$State='Running'
    )

    if($Total -le 0) { return }

    $pct = [math]::Floor(($Current/$Total)*100)
    $width = 24
    $filled = [math]::Floor(($pct/100)*$width)
    $bar = ('#' * $filled) + ('-' * ($width-$filled))
    $color = if($State -eq 'Failed') {'Red'} elseif($State -eq 'Completed') {'Green'} else {'Cyan'}

    Write-Host (" [{0}] {1,3}%  {2,3}/{3,-3}  {4}: {5}" -f `
        $bar,$pct,$Current,$Total,$State,$ModuleName) -ForegroundColor $color
}

Export-ModuleMember -Function `
    Write-WSLogo,
    Write-WSHeader,
    Select-WSModulesInteractive,
    Resolve-WSModuleIds,
    Show-WSCompactModuleList,
    Show-WSMainGroupSummary,
    Show-WSSubGroupSummary,
    Show-WSLeafGroupSummary,
    Get-WSLocalMenuChoice,
    Write-WSRunProgress,
    Test-WSAdmin
