<#
.SYNOPSIS
Скрипт для автоматического переименования видеофайлов GoPro с группировкой по дате съемки

.DESCRIPTION
Этот скрипт анализирует видеофайлы GoPro, извлекает дату съемки из имени файла
и переименовывает их в формат: ГГГГ-ММ-ДД_КамераN_КлипM.mp4

.FEATURES
- Автоматически определяет дату съемки из стандартных имен GoPro
- Поддерживает форматы: GHYYMMDD... и GXYYMMDD...
- Для нестандартных имен использует дату изменения файла
- Группирует файлы по дате съемки
- Продолжает нумерацию с учетом уже переименованных файлов
- Интуитивный графический интерфейс выбора папки

.EXAMPLE
.\Rename-GoProVideos.ps1
Запускает графический интерфейс для выбора папки с видеофайлами

.NOTES
Автор: MakXander
Версия: 1.1
Дата: $(Get-Date -Format "yyyy-MM-dd")
#>

#region Инициализация
Add-Type -AssemblyName System.Windows.Forms
#endregion

#region Функции
function Get-GoProDate {
    <#
    .SYNOPSIS
    Извлекает дату съемки из имени файла GoPro
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    
    # Стандартные форматы имен GoPro
    if ($fileName -match '^(GH|GX)(\d{6})') {
        $datePart = $matches[2]
        try {
            $year = [int]("20" + $datePart.Substring(0, 2))
            $month = [int]($datePart.Substring(2, 2))
            $day = [int]($datePart.Substring(4, 2))
            $date = Get-Date -Year $year -Month $month -Day $day -ErrorAction Stop
            return $date.ToString("yyyy-MM-dd")
        }
        catch {
            Write-Host "⚠️ Неверный формат даты в файле: $fileName"
        }
    }
    
    # Резервный вариант: дата последнего изменения
    Write-Host "ℹ️ Для файла $fileName используется дата изменения"
    return (Get-Item $FilePath).LastWriteTime.ToString("yyyy-MM-dd")
}

function Test-RenamedFile {
    <#
    .SYNOPSIS
    Проверяет, соответствует ли имя файла целевому формату
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )
    return $FileName -match '^\d{4}-\d{2}-\d{2}_.+_Клип\d+\.mp4$'
}
#endregion

#region Основной процесс
try {
    # --- Выбор папки ---
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "Выберите папку с видеофайлами GoPro"
    $folderDialog.ShowNewFolderButton = $false
    
    if ($folderDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "❌ Папка не выбрана. Скрипт остановлен." -ForegroundColor Red
        exit
    }
    
    $inputFolder = $folderDialog.SelectedPath
    $cameraName = "Камера1"  # Название камеры (можно изменить)
    
    Write-Host "`n⌛ Обработка папки: $inputFolder" -ForegroundColor Cyan
    
    # --- Сбор и анализ файлов ---
    $allFiles = Get-ChildItem -Path $inputFolder -Filter "*.MP4" -File
    $filesByDate = @{}
    
    if (-not $allFiles) {
        Write-Host "❌ В папке не найдены MP4 файлы" -ForegroundColor Red
        exit
    }
    
    Write-Host "🔍 Найдено файлов: $($allFiles.Count)" -ForegroundColor Cyan
    
    # Группировка файлов по дате съемки
    foreach ($file in $allFiles) {
        $dateKey = Get-GoProDate $file.FullName
        
        if (-not $filesByDate.ContainsKey($dateKey)) {
            $filesByDate[$dateKey] = @{
                Renamed = [System.Collections.Generic.List[object]]::new()
                ToRename = [System.Collections.Generic.List[object]]::new()
            }
        }
        
        if (Test-RenamedFile $file.Name) {
            $filesByDate[$dateKey].Renamed.Add($file)
        }
        else {
            $filesByDate[$dateKey].ToRename.Add($file)
        }
    }
    
    # --- Переименование ---
    $totalRenamed = 0
    
    foreach ($date in $filesByDate.Keys) {
        $renamedFiles = $filesByDate[$date].Renamed
        $toRenameFiles = $filesByDate[$date].ToRename | Sort-Object Name
        
        # Определение стартового номера
        $startNumber = 1
        if ($renamedFiles.Count -gt 0) {
            $numbers = $renamedFiles | ForEach-Object {
                if ($_.Name -match '_Клип(\d+)\.mp4$') {
                    [int]$matches[1]
                }
            }
            $startNumber = ($numbers | Measure-Object -Maximum).Maximum + 1
        }
        
        # Переименование файлов
        $counter = $startNumber
        foreach ($file in $toRenameFiles) {
            $newName = "{0}_{1}_Клип{2}.mp4" -f $date, $cameraName, $counter
            $newPath = Join-Path -Path $inputFolder -ChildPath $newName
            
            try {
                Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                Write-Host "✅ $($file.Name) -> $newName" -ForegroundColor Green
                $counter++
                $totalRenamed++
            }
            catch {
                Write-Host "⚠️ Ошибка при переименовании $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    # --- Результаты ---
    Write-Host "`n✅ Переименование завершено!" -ForegroundColor Green
    Write-Host "┌───────────────────────┐"
    Write-Host "│ Обработано файлов: $($allFiles.Count.ToString().PadRight(5)) │"
    Write-Host "│ Переименовано:   $($totalRenamed.ToString().PadRight(5)) │"
    Write-Host "└───────────────────────┘"
    Write-Host "Папка: $inputFolder"
}
catch {
    Write-Host "`n❌ Критическая ошибка: $_" -ForegroundColor Red
    exit 1
}
#endregion
