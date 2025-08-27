# imper

## clone

```shell
git clone --recursive git@github.com:managanemeke/imper.git
```

## install

- win + s -> `powershell`
- right click -> run with admin rights
- `Set-ExecutionPolicy Bypass`
- `Install-Module -Name Microsoft.WinGet.Client`
- `exit`
- win + s -> `powershell`
- `cd "C:\ProgramData\maer\imper"`
- `./install.ps1`

## test

```shell
https --download "https://placehold.co/1408x576/jpg" --output "1408x576.jpg"
```

```shell
./commands/1_1_nightify/file.ps1 "1408x576.jpg"
```

## install

### locate

```shell
$locatePath = "$env:PROGRAMDATA\maer\imper"
New-Item -Path $locatePath -ItemType Directory -Force
Copy-Item -Path "..\imper\*" -Destination $locatePath -Recurse -Force
Set-Location -Path $locatePath
```

### menu

```shell
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_menu.ps1`" `"$PWD\explorer.file.menu.yaml`"" -Verb RunAs -Wait
```

### dependencies

```shell
.\install_dependencies.ps1
```

### python-dependencies

```shell
.\install_dependencies_python.ps1
```

## check

### dependencies

```shell
.\check_dependencies.ps1
```

## delete

### menu

```shell
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\delete_menu.ps1`" `"$PWD\explorer.file.menu.yaml`"" -Verb RunAs -Wait
```
