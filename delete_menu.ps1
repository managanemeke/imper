$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

if (-not (Get-Module -Name powershell-yaml -ListAvailable)) {
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

function Remove-Reg {
    param($path)
    & cmd.exe /c "reg delete `"$path`" /f" 2>$null
}

function Get-ChildShellPath {
    param($parentPath, $name)
    return "$parentPath\shell\$name"
}

function Remove-ContextMenuCommand {
    param($parentPath, $name)

    if ($parentPath -eq "" -or $name -eq "") {
        return
    }

    $childShellPath = Get-ChildShellPath $parentPath $name
    Remove-Reg $childShellPath
}

function Process-CommandsForRemoval {
    param($parentPath, $commands)

    foreach ($cmdName in $commands.Keys) {
        $cmd = $commands[$cmdName]

        Remove-ContextMenuCommand -parentPath $parentPath -name $cmdName

        if ($cmd.commands -and $cmd.commands.Count -gt 0) {
            $currentPath = Get-ChildShellPath $parentPath $cmdName
            Process-CommandsForRemoval -parentPath $currentPath -commands $cmd.commands
        }
    }
}

if ($args.Count -eq 0) {
    Write-Host "Usage: delete_menu.ps1 <yaml-config-file>"
    exit 1
}

$yamlPath = $args[0]
if (-not (Test-Path $yamlPath)) {
    Write-Host "Configuration file not found: $yamlPath"
    exit 1
}

try {
    $yamlContent = Get-Content $yamlPath -Raw
    $config = ConvertFrom-Yaml $yamlContent
}
catch {
    Write-Host "Loading yaml-file error: $_"
    exit 1
}

$root = $config.root
if (-not $root) {
    Write-Host "No root in configuration"
    exit 1
}

if ($config.commands) {
    Process-CommandsForRemoval -parentPath $root -commands $config.commands
}

Write-Host "Menu from $yamlPath successfully removed"
