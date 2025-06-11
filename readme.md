# impersonal

## install

### dependencies

```shell
winget import --import-file "packages.json" --accept-package-agreements --accept-source-agreements
```

### menu

```shell
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\install_file.ps1`"" -Verb RunAs
```

### structures

```shell
git clone https://github.com/managanemeke/meeseeks-box-structures.git structures
```
