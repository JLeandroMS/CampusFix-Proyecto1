@echo off
cd /d "%~dp0\.."
call flutter pub get
if errorlevel 1 goto error
call npm run seed
if errorlevel 1 goto error
call flutter run -d chrome --web-port 5000 --dart-define=USE_EMULATORS=true
pause
exit /b
:error
echo Revise que Flutter, Node y los emuladores esten disponibles.
pause
