# CampusFix — empieza aquí

Proyecto IF0009 · Universidad de Costa Rica, Sede del Sur · II Ciclo 2026.

## Qué recibes y qué falta verificar

El código implementa las 20 historias del enunciado, incluidas las pantallas y configuración de publicación. Las reglas se probaron contra emuladores. **No se ha compilado ni desplegado la aplicación Flutter**: la revisión automática de este entorno bloqueó el arranque del SDK al detectar una solicitud a metadatos de nube. El formateador Dart sí revisó la sintaxis, pero eso no sustituye `flutter analyze`, `flutter test` ni una compilación. Los resultados exactos están en `docs/PRUEBAS.md`.

No hay una URL pública ni un repositorio remoto inventados. Antes de entregar al profesor hay que ejecutar las verificaciones Flutter, conectar un proyecto Firebase propio, publicarlo y tomar capturas reales. El ZIP conserva un repositorio Git local con commits auténticos de esta implementación.

## Opción 1: probar localmente sin una cuenta Firebase

Requisitos: Flutter estable >=3.35 (Dart >=3.9), Chrome, Node.js 22 y JDK 21. Node ejecuta las herramientas Firebase, no reemplaza Flutter.

1. Extrae el ZIP y abre la carpeta `campusfix` en VS Code.
2. En una terminal comprueba `flutter doctor`, `node --version` y `java -version`.
3. Ejecuta `scripts\emuladores.bat` en Windows. Déjala abierta.
4. En otra terminal ejecuta `scripts\iniciar_local.bat`.
5. Se abre Chrome con Flutter conectado a emuladores locales.

Equivalente en cualquier sistema:

```sh
npm ci
npx firebase emulators:start --project demo-campusfix --only auth,firestore,storage
```

En otra terminal:

```sh
flutter pub get
npm run seed
flutter run -d chrome --web-port 5000 --dart-define=USE_EMULATORS=true
```

| Rol local | Correo | Contraseña de demostración local |
|---|---|---|
| Administrador | admin@campusfix.test | CampusFix2026! |
| Técnico | tecnico@campusfix.test | CampusFix2026! |
| Reportante | usuario@campusfix.test | CampusFix2026! |

Estas cuentas solo se crean en emuladores. Nunca se crean en producción. El script de semillas restaura sus roles y los catálogos si lo vuelves a ejecutar. Al apagar emuladores se pierden los datos, salvo que configures exportación/importación de Firebase Emulator Suite.

Para demostrar roles abre ventanas o perfiles de navegador independientes. Dos pestañas del mismo perfil pueden compartir la sesión de Authentication.

## Opción 2: conectar y publicar tu Firebase

Sigue `docs/DESPLIEGUE.md`. Se necesitan valores reales de configuración, acceso a tu proyecto y los servicios habilitados. No envíes contraseñas, claves de cuenta de servicio ni tokens al chat.

## Verificar antes de entregar

Con los emuladores anteriores detenidos para no ocupar puertos:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define=USE_EMULATORS=true
npm ci
npm run test:rules
```

En Windows puedes usar `scripts\verificar.bat`. Las pruebas de reglas usan puertos 8080 y 9199. No las ejecutes contra emuladores de una demostración que quieras conservar: limpian sus datos de prueba.

## Archivos importantes

- `README.md`: mapa general y responsabilidades.
- `docs/REQUISITOS.md`: historias, criterios y relación con código.
- `docs/ARQUITECTURA.md`: capas, modelo y decisiones.
- `docs/MANUAL_USUARIO.md`: cómo utilizar cada rol.
- `docs/PRUEBAS.md`: resultados reales y guion pendiente.
- `docs/DESPLIEGUE.md`: Firebase, publicación y GitHub.
- `docs/prototipo.html`: prototipo visual de referencia, con datos ficticios; no es la aplicación Flutter.
- `docs/ENTREGA.md`: comprobación final del trabajo.
