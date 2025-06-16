& winget import --import-file "packages.json" --accept-package-agreements --accept-source-agreements
[System.Console]::ReadKey()

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_file.ps1`"" -Verb RunAs
[System.Console]::ReadKey()

& ffmpeg
& git --version
[System.Console]::ReadKey()

& git clone https://github.com/managanemeke/meeseeks-box-structures.git structures
[System.Console]::ReadKey()
