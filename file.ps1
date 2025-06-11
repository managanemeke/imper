param(
    [string]$inputFile
)

Add-Type -AssemblyName System.Drawing

function ConvertTo-Mp4Video {
    param($inputPath, $outputPath, $duration, $fadeIn, $fadeOut)
    $fadeOutStart = [int]$duration - [int]$fadeOut

    & ffmpeg -loop 1 -i $inputPath `
         -vf "fade=in:st=0:d=$fadeIn, fade=out:st=${fadeOutStart}:d=$fadeOut" `
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
        $dimension = "${width}x${height}"

        if (
            $dimension -eq "1408x576" -or $dimension -eq "3200x1344"
        ) {
            ConvertTo-Mp4Video $inputPath $outputPath 65 8 8
            return
        }
        if ($dimension -eq "2368x640") {
            ConvertTo-Mp4Video $inputPath $outputPath 60 8 8
            return
        }
        ConvertTo-Mp4Video $inputPath $outputPath 60 6 6
    }
}

function ConvertTo-Mp4VideoInSameDirectory {
    param($inputPath)

    $withoutExtension = [System.IO.Path]::Combine(
        [System.IO.Path]::GetDirectoryName($inputPath),
        [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    )
    $outputFile = "$withoutExtension.mp4"

    ConvertTo-Mp4VideoFromImage $inputPath $outputFile
}

try {
    ConvertTo-Mp4VideoInSameDirectory $inputFile
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
