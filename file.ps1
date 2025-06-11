param(
    [string]$inputFile
)

function ConvertTo-Mp4Video {
    param($inputPath, $outputPath)

    & ffmpeg -loop 1 -i $inputPath `
             -vf "fade=in:st=0:d=5, fade=out:st=55:d=5" `
             -c:v h264 -t 60 `
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
        ConvertTo-Mp4Video $inputPath $outputPath
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
