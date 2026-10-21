@echo off
cd /d "%~dp0\.."
call npm run seed
if errorlevel 1 (
 echo Inicie primero scripts\emuladores.bat y espere a que los emuladores esten listos.
 pause
 exit /b 1
)
start "" http://127.0.0.1:5000
node scripts/serve_web.mjs
pause
