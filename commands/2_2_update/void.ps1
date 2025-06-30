$scriptDirectory = $PSScriptRoot

Set-Location -Path $scriptDirectory
Set-Location ..
Set-Location ..

git pull --recurse-submodules origin main
