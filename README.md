# GoProRenamer

🔄 Утилита на PowerShell для автоматического переименования видеофайлов с камер GoPro по дате съёмки.

## 📂 Как работает

1. Выбор папки через графическое окно.
2. Поиск всех `.MP4` файлов.
3. Определение даты съёмки по имени файла (или дате изменения).
4. Переименование в формат: `ГГГГ-ММ-ДД_Камера1_КлипN.mp4`

## 📥 Пример

**До:**
GH010123.MP4
GX021224.MP4
**После:**
2023-01-23_Камера1_Клип1.mp4
2024-12-24_Камера1_Клип1.mp4

🚀 Установка и запуск
📥 1. Скачивание
Способ 1: Через релиз
Перейдите в Releases и скачайте файл GoProRenamer.ps1 или .zip-архив.

Способ 2: Через git (если установлен Git):
git clone https://github.com/BearMarstar/GoPro-Video-Renamer/.git

▶️ 2. Запуск
Вариант A: Через контекстное меню (GUI способ)
Щёлкните правой кнопкой по GoPro-Video-Renamer.ps1

Выберите: Запуск с PowerShell

⚠️ Убедитесь, что в свойствах файла нет блокировки ("Разблокировать" на вкладке Общие).


Вариант B: Через PowerShell
Откройте PowerShell (Win+R → powershell)

Перейдите в папку со скриптом:
cd "C:\путь\до\GoPro-Video-Renamer"

Запустите:
.\GoPro-Video-Renamer.ps1

🛡️ Возможная ошибка: execution of scripts is disabled
Если PowerShell выдаёт ошибку типа:
File GoPro-Video-Renamer.ps1 cannot be loaded because running scripts is disabled...

Тогда нужно временно разрешить запуск скриптов:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\GoPro-Video-Renamer.ps1

⚠️ Это разрешение действует только в этом сеансе PowerShell — безопасно.

📂 После запуска
Появится окно выбора папки. Выберите папку с видеофайлами GoPro — скрипт автоматически переименует их по дате съёмки.


## ✅ Требования

- PowerShell 5.1+
- Windows (используется `System.Windows.Forms`)

## ⚖️ Лицензия

MIT
