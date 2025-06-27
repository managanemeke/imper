param(
    [string]$inputFile
)

Add-Type -AssemblyName System.Drawing

$scriptPath = $PSScriptRoot

$structures = Import-Csv -Path "$scriptPath\structures\structures.csv" -Delimiter ";"

function ConvertTo-Mp4Video {
    param($inputPath, $outputPath, $duration, $fade_in, $fade_out)
    $fadeOutStart = [int]$duration - [int]$fade_out

    & ffmpeg -loop 1 -i "$inputPath" `
         -vf "fade=in:st=0:d=$fade_in, fade=out:st=${fadeOutStart}:d=$fade_out" `
         -c:v h264 -t $duration `
         -pix_fmt yuv420p `
         "$outputPath" `
         -y
}

function Get-ExtensionWithoutDot {
    param($filePath, [ref]$outVar)

    $extension = [System.IO.Path]::GetExtension($filePath).Substring(1)
    if ($outVar) {
        $outVar.Value = $extension
    }
    return $extension
}

function ConvertTo-Mp4VideoFromImage {
    param($inputPath, $outputPath)

    $extension = Get-ExtensionWithoutDot $inputPath
    if (@("png", "jpg", "jpeg") -contains $extension) {
        $image = [System.Drawing.Image]::FromFile($inputPath);
        $width = $image.Width
        $height = $image.Height

        $structure = $structures | Where-Object {
            [int]$_.width -eq $width -and [int]$_.height -eq $height -and [int]$_.has_night_mode -eq 1
        } | Select-Object -First 1

        if ($structure) {
            ConvertTo-Mp4Video "$inputPath" "$outputPath" $structure.duration $structure.fade_in $structure.fade_out
            return
        }
    }
}

function ConvertTo-Mp4VideoInSameDirectory {
    param($inputPath)

    $withoutExtension = [System.IO.Path]::Combine(
        [System.IO.Path]::GetDirectoryName($inputPath),
        [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    )
    $outputFile = "$withoutExtension.mp4"

    ConvertTo-Mp4VideoFromImage "$inputPath" "$outputFile"
}

try {
    ConvertTo-Mp4VideoInSameDirectory "$inputFile"
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
