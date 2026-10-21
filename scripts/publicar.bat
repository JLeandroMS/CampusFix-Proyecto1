@echo off
cd /d "%~dp0\.."
if "%~1"=="" (
  echo Uso: scripts\publicar.bat TU_PROJECT_ID
  exit /b 1
)
if not exist config\firebase.json (
  echo Copie y complete config\firebase.example.json como config\firebase.json.
  exit /b 1
)
call flutter pub get
if errorlevel 1 exit /b 1
call flutter analyze
if errorlevel 1 exit /b 1
call flutter test
if errorlevel 1 exit /b 1
call flutter build web --no-web-resources-cdn --release --dart-define-from-file=config/firebase.json
if errorlevel 1 exit /b 1
call npx firebase deploy --project %1 --only firestore:rules,firestore:indexes,storage,hosting
