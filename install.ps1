Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_dependencies.ps1`"" -Wait

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_menu.ps1`" `"$PWD\explorer.file.menu.yaml`"" -Verb RunAs -Wait

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\check_dependencies.ps1`"" -Wait
