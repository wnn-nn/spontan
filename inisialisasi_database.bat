@echo off
echo ========================================================
echo        INISIALISASI DATABASE MYSQL UNTUK SPONTAN
echo ========================================================
echo.
cd /d "%~dp0backend"
node src/scripts/initDb.js
echo.
pause
