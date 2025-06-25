Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_dependencies.ps1`""

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_file.ps1`"" -Verb RunAs

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\check_dependencies.ps1`""
