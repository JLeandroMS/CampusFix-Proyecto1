@echo off
cd /d "%~dp0\.."
call flutter pub get
if errorlevel 1 goto error
call flutter analyze
if errorlevel 1 goto error
call flutter test
if errorlevel 1 goto error
call flutter build web --no-web-resources-cdn --dart-define=USE_EMULATORS=true
if errorlevel 1 goto error
call npm ci
if errorlevel 1 goto error
call npm run test:rules
if errorlevel 1 goto error
echo Verificaciones completadas.
pause
exit /b
:error
echo Una verificacion fallo. Revise el mensaje anterior.
pause
exit /b 1
