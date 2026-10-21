# CampusFix — empieza aquí

Proyecto IF0009 · Universidad de Costa Rica, Sede del Sur · II Ciclo 2026.

## Qué recibes y qué falta verificar

La aplicación compiló correctamente con Flutter 3.47.7 / Dart 3.13.5. `flutter analyze` terminó sin incidencias y las 8 pruebas Flutter pasaron. También se aprobaron 28 pruebas de reglas Firebase y 12 comprobaciones independientes de dominio. Los resultados están en `docs/PRUEBAS.md`. La publicación real requiere conectar tu proyecto Firebase.

No hay una URL pública ni un repositorio remoto inventados. Antes de entregar al profesor hay que conectar un proyecto Firebase propio, publicarlo y completar la verificación en ese entorno. El ZIP conserva un repositorio Git local con commits auténticos de esta implementación.

## Prueba rápida con el build incluido (sin instalar Flutter)

El ZIP incluye `build/web`, compilado para **emuladores locales**, no para producción.

1. Instala Node.js 22 y JDK 21.
2. Ejecuta `scripts\emuladores.bat` y espera a que indique que los emuladores están listos.
3. En otra ventana ejecuta `scripts\abrir_build_local.bat`.
4. Abre http://127.0.0.1:5000 y usa las cuentas de demostración indicadas abajo.

El navegador todavía necesita Internet para cargar los SDK oficiales de Firebase. Gráficos CanvasKit y tipografías están incluidos localmente. Para editar/recompilar el código utiliza la opción siguiente.

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
flutter build web --no-web-resources-cdn --dart-define=USE_EMULATORS=true
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
