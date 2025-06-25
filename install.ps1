& winget import --import-file "packages.json" --accept-package-agreements --accept-source-agreements

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_file.ps1`"" -Verb RunAs

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\check_dependencies.ps1`""
