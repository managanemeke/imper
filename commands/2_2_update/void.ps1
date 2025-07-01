$scriptDirectory = $PSScriptRoot

Set-Location -Path $scriptDirectory
Set-Location ..
Set-Location ..

$repository = "https://github.com/managanemeke/meeseeks-box-structures.git"
$branch = "main"
$fileName = "structures.csv"
$filePath = "$fileName"
$directory = "structures"

Remove-Item -Path $directory -Recurse -Force

git clone --depth 1 --branch $branch --filter=blob:none --no-checkout $repository $directory

Set-Location $directory
git sparse-checkout init --no-cone
git sparse-checkout set --no-cone "$filePath"
git checkout $branch
