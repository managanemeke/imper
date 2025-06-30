$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$applicationRoot = $PSScriptRoot

if (-not (Get-Module -Name powershell-yaml -ListAvailable)) {
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

function Add-Reg {
    param($path, $arguments)
    & cmd.exe /c "reg add `"$path`" $arguments"
}

function Add-RegDefaultEntry {
    param($path, $value)
    Add-Reg $path "/f /ve /d `"$value`""
}

function Add-RegEntry {
    param($path, $name, $type, $value)
    Add-Reg $path "/f /v $name /t $type /d `"$value`""
}

function Add-RegFolder {
    param($path)
    Add-Reg $path "/f"
}

function Get-ChildShellPath {
    param($parentPath, $name)
    return "$parentPath\shell\$name"
}

function Get-CommandPath {
    param($path)
    return "$path\command"
}

function Add-ContextMenuCommand {
    param($parentPath, $name, $title, $position, $hasSubCommands, $command)

    if ($parentPath -eq "" -or $name -eq "") {
        return
    }

    $childShellPath = Get-ChildShellPath $parentPath $name
    Add-RegFolder $childShellPath

    if ($title -ne "") {
        Add-RegEntry $childShellPath "MUIVerb" "REG_SZ" $title
    }

    if ($position -ne "" -and $position -ne $null) {
        Add-RegEntry $childShellPath "Position" "REG_SZ" $position
    }

    if ($hasSubCommands -eq $true) {
        Add-RegEntry $childShellPath "SubCommands" "REG_SZ" ""
    }

    if ($command -ne "") {
        $commandPath = Get-CommandPath $childShellPath
        Add-RegFolder $commandPath
        Add-RegDefaultEntry $commandPath $command
    }
}

function Process-Commands {
    param($parentPath, $commands)

    $psPath = (Get-Command powershell).Source

    foreach ($cmdName in $commands.Keys) {
        $cmd = $commands[$cmdName]

        $processedCommand = $cmd.command -replace '\{\{APPDIR\}\}', $applicationRoot -replace '\{\{POWERSHELL\}\}', "`"$psPath`""

        Add-ContextMenuCommand -parentPath $parentPath -name $cmdName -title $cmd.title -position $cmd.position -hasSubCommands $cmd.hasSubCommands -command $processedCommand

        if ($cmd.commands -and $cmd.commands.Count -gt 0) {
            $currentPath = Get-ChildShellPath $parentPath $cmdName
            Process-Commands -parentPath $currentPath -commands $cmd.commands
        }
    }
}

if ($args.Count -eq 0) {
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

Add-RegFolder $root

if ($config.commands) {
    Process-Commands -parentPath $root -commands $config.commands
}

Write-Host "Menu from $yamlPath succussfully created"
