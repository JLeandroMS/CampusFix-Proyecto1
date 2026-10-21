@echo off
cd /d "%~dp0\.."
call npm ci
if errorlevel 1 goto error
call npx firebase emulators:start --project demo-campusfix --only auth,firestore,storage
pause
exit /b
:error
echo No se pudieron instalar las herramientas. Revise Node.js y su conexion.
pause
