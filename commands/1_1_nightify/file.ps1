param(
    [string]$inputFile
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

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

function Show-StructureSelectionDialog {
    param($matchingStructures)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Выбор конструкции"
    $form.Size = New-Object System.Drawing.Size(450, 350)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(400, 20)
    $label.Text = "Найдено несколько подходящих конструкций. Выберите одну:"
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 50)
    $listBox.Size = New-Object System.Drawing.Size(400, 200)
    $listBox.SelectionMode = "One"
    $listBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10)

    foreach ($structure in $matchingStructures) {
        $listBox.Items.Add("$($structure.name) | Длительность: $($structure.duration)с | FadeIn: $($structure.fade_in)с | FadeOut: $($structure.fade_out)с") | Out-Null
    }
    $form.Controls.Add($listBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(300, 260)
    $okButton.Size = New-Object System.Drawing.Size(100, 30)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Add_Click({
        if ($listBox.SelectedIndex -eq -1) {
            [System.Windows.Forms.MessageBox]::Show("Пожалуйста, выберите конструкцию!", "Ошибка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            $form.DialogResult = [System.Windows.Forms.DialogResult]::None
        }
    })
    $form.Controls.Add($okButton)
    $form.AcceptButton = $okButton

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(190, 260)
    $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
    $cancelButton.Text = "Отмена"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancelButton)
    $form.CancelButton = $cancelButton

    $form.Topmost = $true
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $listBox.SelectedIndex -ne -1) {
        return $matchingStructures[$listBox.SelectedIndex]
    }
    return $null
}

function Measure-HaveStructuresSameNightMode {
    param($structures)

    if ($structures.Count -le 1) {
        return $true
    }

    $first = $structures[0]
    foreach ($structure in $structures) {
        if ($structure.duration -ne $first.duration -or
                $structure.fade_in -ne $first.fade_in -or
                $structure.fade_out -ne $first.fade_out) {
            return $false
        }
    }
    return $true
}

function ConvertTo-Mp4VideoFromImage {
    param($inputPath, $outputPath)

    $extension = Get-ExtensionWithoutDot $inputPath
    if (@("png", "jpg", "jpeg") -contains $extension) {
        $image = [System.Drawing.Image]::FromFile($inputPath)
        $width = $image.Width
        $height = $image.Height

        $matchingStructures = @($structures | Where-Object {
            [int]$_.width -eq $width -and [int]$_.height -eq $height -and [int]$_.has_night_mode -eq 1
        })

        if ($matchingStructures.Count -eq 0) {
            return
        }
        elseif ((Measure-HaveStructuresSameNightMode $matchingStructures)) {
            $selectedStructure = $matchingStructures[0]
        }
        else {
            $selectedStructure = Show-StructureSelectionDialog $matchingStructures
            if (-not $selectedStructure) {
                return
            }
        }

        ConvertTo-Mp4Video "$inputPath" "$outputPath" $selectedStructure.duration $selectedStructure.fade_in $selectedStructure.fade_out
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
