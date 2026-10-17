@echo off
echo ========================================================
echo      MEMULAI BACKEND SPONTAN DAN REVERSE PORT HP USB
echo ========================================================
echo.

echo [1/2] Menghubungkan port HP (adb reverse tcp:5000 tcp:5000)...
if exist "C:\Android\platform-tools\adb.exe" (
    "C:\Android\platform-tools\adb.exe" reverse tcp:5000 tcp:5000
    echo ADB reverse berhasil disiapkan.
) else (
    adb reverse tcp:5000 tcp:5000 2>nul
)

echo.
echo [2/2] Menjalankan server backend Express.js...
cd /d "%~dp0backend"
npm run dev
