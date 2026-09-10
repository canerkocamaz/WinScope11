Set-StrictMode -Version Latest

function Get-WSHierarchyDefinition {
    param([Parameter(Mandatory)][string]$ProjectRoot)

    $path = Join-Path $ProjectRoot 'Config\hierarchy.json'
    if(-not (Test-Path -LiteralPath $path)) {
        throw "Hierarchy definition not found: $path"
    }

    return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Get-WSModuleCatalog {
    param([Parameter(Mandatory)][string]$ProjectRoot)

    $moduleRoot = Join-Path $ProjectRoot 'Modules'
    if (-not (Test-Path -LiteralPath $moduleRoot)) {
        throw "Modules directory not found: $moduleRoot"
    }

    $hierarchy = Get-WSHierarchyDefinition -ProjectRoot $ProjectRoot
    $map = @{}
    foreach($entry in @($hierarchy.Mappings)) {
        $map[[string][int]$entry.SourceGroupId] = $entry
    }

    [object[]]$items = @()

    Get-ChildItem -LiteralPath $moduleRoot -Filter '*.ps1' -File -Recurse -ErrorAction Stop |
        Sort-Object FullName |
        ForEach-Object {
            try {
                $meta = & $_.FullName
                if ($null -eq $meta) { return }

                $sourceGroupId = [int]$meta.GroupId
                $sourceGroupName = [string]$meta.Group
                $key = [string]$sourceGroupId

                if(-not $map.ContainsKey($key)) {
                    throw "No hierarchy mapping for source GroupId $sourceGroupId"
                }

                $h = $map[$key]

                $meta | Add-Member -NotePropertyName DescriptorPath  -NotePropertyValue $_.FullName -Force
                $meta | Add-Member -NotePropertyName SourceGroupId   -NotePropertyValue $sourceGroupId -Force
                $meta | Add-Member -NotePropertyName SourceGroupName -NotePropertyValue $sourceGroupName -Force

                $meta | Add-Member -NotePropertyName MainGroupCode -NotePropertyValue ([string]$h.MainGroupCode) -Force
                $meta | Add-Member -NotePropertyName MainGroupName -NotePropertyValue ([string]$h.MainGroupName) -Force
                $meta | Add-Member -NotePropertyName SubGroupCode  -NotePropertyValue ([string]$h.SubGroupCode) -Force
                $meta | Add-Member -NotePropertyName SubGroupName  -NotePropertyValue ([string]$h.SubGroupName) -Force
                $meta | Add-Member -NotePropertyName LeafGroupCode -NotePropertyValue ([string]$h.LeafGroupCode) -Force
                $meta | Add-Member -NotePropertyName LeafGroupName -NotePropertyValue ([string]$h.LeafGroupName) -Force

                $items += $meta
            } catch {
                throw "Failed loading module descriptor '$($_.FullName)': $($_.Exception.Message)"
            }
        }

    $catalog = @($items | Sort-Object Id)
    $ids = @($catalog | Select-Object -ExpandProperty Id)

    if ($ids.Count -ne ($ids | Select-Object -Unique).Count) {
        throw 'Duplicate WinScope module ID detected.'
    }

    return $catalog
}

function Get-WSGroupCatalog {
    param([Parameter(Mandatory)][object[]]$Modules)

    return @(
        $Modules |
            Group-Object MainGroupCode |
            ForEach-Object {
                $first = $_.Group | Sort-Object Id | Select-Object -First 1
                [pscustomobject]@{
                    Id          = [int]$first.MainGroupCode
                    Code        = [string]$first.MainGroupCode
                    Name        = [string]$first.MainGroupName
                    ModuleCount = $_.Count
                }
            } |
            Sort-Object Id
    )
}

function Get-WSSubGroupCatalog {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$MainGroupCode
    )

    return @(
        $Modules |
            Where-Object MainGroupCode -eq $MainGroupCode |
            Group-Object SubGroupCode |
            ForEach-Object {
                $first = $_.Group | Sort-Object Id | Select-Object -First 1
                [pscustomobject]@{
                    Code        = [string]$first.SubGroupCode
                    Name        = [string]$first.SubGroupName
                    MainCode    = [string]$first.MainGroupCode
                    ModuleCount = $_.Count
                }
            } |
            Sort-Object Code
    )
}

function Get-WSLeafGroupCatalog {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$SubGroupCode
    )

    return @(
        $Modules |
            Where-Object SubGroupCode -eq $SubGroupCode |
            Group-Object LeafGroupCode |
            ForEach-Object {
                $first = $_.Group | Sort-Object Id | Select-Object -First 1
                [pscustomobject]@{
                    Code        = [string]$first.LeafGroupCode
                    Name        = [string]$first.LeafGroupName
                    SubCode     = [string]$first.SubGroupCode
                    MainCode    = [string]$first.MainGroupCode
                    ModuleCount = $_.Count
                }
            } |
            Sort-Object Code
    )
}

function Get-WSModulesByHierarchyTarget {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$Target
    )

    $code = $Target.Trim()
    if($code -match '^(?i:G)(.+)$') {
        $code = $Matches[1].Trim()
    }

    if($code -match '^\d+$') {
        return @($Modules | Where-Object MainGroupCode -eq $code | Sort-Object Id)
    }

    if($code -match '^\d+\.\d+$') {
        return @($Modules | Where-Object SubGroupCode -eq $code | Sort-Object Id)
    }

    if($code -match '^\d+\.\d+\.\d+$') {
        return @($Modules | Where-Object LeafGroupCode -eq $code | Sort-Object Id)
    }

    return @()
}

function Find-WSModule {
    param(
        [Parameter(Mandatory)][object[]]$Modules,
        [Parameter(Mandatory)][string]$Query
    )

    $numeric = 0
    if ([int]::TryParse($Query, [ref]$numeric)) {
        return @($Modules | Where-Object Id -eq $numeric)
    }

    return @(
        $Modules |
            Where-Object {
                $_.Name -like "*$Query*" -or
                $_.SourceGroupName -like "*$Query*" -or
                $_.MainGroupName -like "*$Query*" -or
                $_.SubGroupName -like "*$Query*" -or
                $_.LeafGroupName -like "*$Query*" -or
                $_.Description -like "*$Query*"
            } |
            Sort-Object Id
    )
}

Export-ModuleMember -Function `
    Get-WSHierarchyDefinition,
    Get-WSModuleCatalog,
    Get-WSGroupCatalog,
    Get-WSSubGroupCatalog,
    Get-WSLeafGroupCatalog,
    Get-WSModulesByHierarchyTarget,
    Find-WSModule
