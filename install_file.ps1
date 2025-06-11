$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$scriptPath = $PSScriptRoot
$name = "Ночная статика"
$position = "Bottom"
$command = "`"$((Get-Command powershell).Source)`" -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath\file.ps1`" `"`"`%1`"`""

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

function Add-ContextMenuItemForType {
    param($type)

    $path = "HKCR\$type\shell\$name"
    $commandPath = "$path\command"

    Add-RegFolder $path
    Add-RegEntry $path "MUIVerb" "REG_SZ" $name
    Add-RegEntry $path "Position" "REG_SZ" $position
    Add-RegFolder $commandPath
    Add-RegDefaultEntry $commandPath $command
}

Add-ContextMenuItemForType "*"
