$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$applicationRoot = $PSScriptRoot

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

    if ($position -ne "") {
        Add-RegEntry $childShellPath "Position" "REG_SZ" $position
    }

    if ($hasSubCommands -eq "true") {
        Add-RegEntry $childShellPath "SubCommands" "REG_SZ" ""
    }

    if ($command -ne "") {
        $commandPath = Get-CommandPath $childShellPath
        Add-RegFolder $commandPath
        Add-RegDefaultEntry $commandPath $command
    }
}

$root = "HKCR\.386"
$imperCommandName = "imper"

Add-ContextMenuCommand $root $imperCommandName "Незам" "Bottom" "true" ""

$imperCommandPath = Get-ChildShellPath $root $imperCommandName

$command = "`"$((Get-Command powershell).Source)`" -NoProfile -ExecutionPolicy Bypass -File `"$applicationRoot\file.ps1`" `"`"`%1`"`""
Add-ContextMenuCommand $imperCommandPath "1_1_nightify" "Заночевать" "" "false" $command

Add-ContextMenuCommand $imperCommandPath "1_2_compress" "Сжать" "" "false" ""

Add-ContextMenuCommand $imperCommandPath "2_1_configure" "Настроить" "" "false" ""

$command = "`"$((Get-Command powershell).Source)`" -NoProfile -ExecutionPolicy Bypass -File `"$applicationRoot\commands\2_2_update\void.ps1`""
Add-ContextMenuCommand $imperCommandPath "2_2_update" "Обновить" "" "false" $command
