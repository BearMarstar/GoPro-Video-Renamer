# GoPro Video Renamer

Скрипт PowerShell для автоматического переименования видеофайлов GoPro

## Особенности

- 📅 Автоматическое определение даты съемки из метаданных имени файла
- 🔢 Интеллектуальная нумерация с группировкой по датам
- 🖼️ Графический интерфейс выбора папки
- ✅ Пропуск уже переименованных файлов
- 📊 Подробный отчет о выполнении

## Как использовать

1. Склонируйте репозиторий:
```powershell
git clone https://github.com/BearMarstar/GoPro-Video-Renamer.git

cd GoPro-Video-Renamer
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\Rename-GoProVideos.ps1
