# Configuración de Firebase, publicación y Git

## Estado actual

No se creó ningún proyecto externo ni se publicó con una cuenta ajena. No existe una URL de entrega confirmada. La configuración preparada requiere tus valores reales y completar la verificación Flutter. La revisión automática bloqueó el arranque del SDK en este entorno por un intento de acceso a metadatos de nube; no se reintentó ese acceso.

## 1. Preparar tu proyecto

1. Abre https://console.firebase.google.com/ con tu cuenta y crea o selecciona un proyecto.
2. Registra una aplicación Web. Copia los campos de configuración pública de la app.
3. Authentication → Sign-in method: habilita Email/Password.
4. Firestore Database: crea la base `(default)` en la región que el equipo elija. Usa las reglas del repositorio, nunca reglas abiertas como entrega final.
5. Storage: crea el bucket y copia su nombre exacto. No asumas sufijo `.appspot.com`; los nuevos buckets pueden usar otro formato.
6. Si Firebase solicita facturación para Storage, la persona propietaria debe revisarla y habilitarla desde su cuenta; el emulador permite pruebas sin ese trámite.
7. En Authentication → Settings → Authorized domains, comprueba el dominio de Hosting. Para pruebas locales con Firebase real, agrega localhost si hace falta.

Instala herramientas locales:

```sh
npm ci
npx firebase login
npx firebase projects:list
```

No pongas claves privadas de servicio, archivos de credenciales o tokens dentro del repositorio. La configuración pública Web identifica el proyecto; la autorización se controla mediante reglas.

## 2. Completar la configuración Web

Copia `config/firebase.example.json` como `config/firebase.json` y sustituye todos los valores por los de tu aplicación:

| Campo de Firebase | Campo del archivo |
|---|---|
| apiKey | FIREBASE_API_KEY |
| appId | FIREBASE_APP_ID |
| messagingSenderId | FIREBASE_MESSAGING_SENDER_ID |
| projectId | FIREBASE_PROJECT_ID |
| authDomain | FIREBASE_AUTH_DOMAIN |
| storageBucket | FIREBASE_STORAGE_BUCKET |

No cambies `USE_EMULATORS` a true en un build de producción. La aplicación usa FirebaseOptions desde `--dart-define-from-file`; por eso no requiere un archivo firebase_options.dart generado. FlutterFire CLI es otra opción oficial de configuración, pero no es necesario combinar ambas estrategias.

Para probar contra tu proyecto real:

```sh
flutter pub get
flutter run -d chrome --web-port 5000 --dart-define-from-file=config/firebase.json
```

Antes de usarlo, publica las reglas con tu ID real:

```sh
npx firebase deploy --project TU_PROJECT_ID --only firestore:rules,firestore:indexes,storage
```

La primera publicación de reglas Storage con acceso a Firestore puede solicitar habilitar permisos entre servicios. Completa la configuración desde Firebase; no sustituyas las reglas por acceso público.

## 3. Primer administrador

1. Registra tu cuenta normalmente en la aplicación: nacerá como reportante.
2. Como propietario autorizado del proyecto, abre Firestore desde Firebase Console.
3. Localiza `users/{tu uid}` y cambia únicamente `role` a `administrador`.
4. La app escucha ese perfil; vuelve a ingresar si es necesario.
5. Desde Administración crea categorías y asigna rol técnico a una segunda cuenta registrada.

Este paso inicial se realiza desde la consola privilegiada, no desde una puerta trasera en la aplicación. No ejecutes `seed.mjs` para producción: está limitado intencionalmente a emuladores.

## 4. Fotografías privadas y CORS

La app descarga imágenes con getData para evitar almacenar URLs públicas con token. El navegador requiere CORS en el bucket para descargas directas, según la documentación oficial de Firebase.

Copia `config/cors.example.json` como `config/cors.json` y reemplaza los dominios por los de tu proyecto. Conserva localhost solo si vas a usarlo para desarrollo. Con Google Cloud CLI autenticado como propietario:

```sh
gcloud storage buckets update gs://NOMBRE_EXACTO_DEL_BUCKET --cors-file=config/cors.json
```

CORS no reemplaza autorización. Las reglas continúan exigiendo ser parte autorizada del caso. Comprueba una fotografía real desde el dominio publicado antes de entregar.

## 5. Construir y publicar

En Windows, desde la carpeta del proyecto:

```bat
scripts\publicar.bat TU_PROJECT_ID
```

Equivalente manual:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=config/firebase.json
npx firebase deploy --project TU_PROJECT_ID --only firestore:rules,firestore:indexes,storage,hosting
```

El último comando debe mostrar la URL real de Hosting. Ábrela en una ventana nueva, inicia sesión y prueba crear, asignar, atender, resolver y cerrar. Copia esa URL en la entrega y en ENTREGA.md. **No uses un build con emuladores para la entrega pública.**

## 6. Repositorio remoto

El ZIP conserva `.git` con commits de este desarrollo. No reinicies ni borres ese historial. Si tu herramienta de extracción omite carpetas ocultas, extrae el ZIP con una herramienta que las conserve.

Crea un repositorio vacío en GitHub con tu cuenta. No agregues otro README al crearlo. Después:

```sh
git status
git log --oneline
git remote add origin https://github.com/TU_USUARIO/campusfix.git
git push -u origin main
```

Si ya existe origin, revisa primero `git remote -v`; no reemplaces un remoto sin comprobar su destino. GitHub puede pedir autenticación; no escribas tokens en el README.

El workflow `.github/workflows/verify.yml` ejecuta análisis, pruebas Flutter, build de emuladores y reglas. No despliega automáticamente y no contiene secretos de producción.

## 7. Problemas habituales

| Síntoma | Revisión |
|---|---|
| flutter no se reconoce | Instalar Flutter y agregar bin al PATH; abrir nueva terminal |
| npm no se reconoce | Instalar Node.js 22 y abrir nueva terminal |
| Emulador no inicia | JDK 21 y puertos 8080, 9099, 9199 libres |
| permission-denied al listar | Perfil correcto, reglas publicadas y consulta por rol |
| No hay categorías | Crear desde Administración o ejecutar seed solo en local |
| No carga imagen en navegador | Permisos de incidencia, ruta/bucket exactos y CORS |
| Falta configurar Firebase | Completar config/firebase.json o pasar USE_EMULATORS=true |
| Dos ventanas cambian de cuenta juntas | Usar perfiles de navegador independientes |
| Se ven usuarios locales en entrega | Se compiló con emuladores; reconstruir con configuración real |

## Fuentes oficiales

Consultadas el 20 de octubre de 2026:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/firestore/manage-data/transactions
- https://firebase.google.com/docs/storage/flutter/download-files
- https://firebase.google.com/docs/storage/web/download-files
