# Evidencia de pruebas y pendientes

Fecha de ejecución: 20 de octubre de 2026 (Costa Rica).

## Resultados ejecutados

| Comprobación | Resultado real | Evidencia |
|---|---|---|
| Reglas Firestore y Storage en emuladores | 28 aprobadas, 0 fallidas | pruebas-reglas.txt |
| Lógica Dart independiente, sin Flutter ni red | 12 aprobadas | pruebas-dominio.txt |
| Parseo y formato de código Dart | 25 archivos procesados; sin errores sintácticos | formato-dart.txt |
| flutter analyze | Sin incidencias | analisis-flutter.txt |
| flutter test (unitarias y widgets) | 8 aprobadas, 0 fallidas | pruebas-flutter.txt |
| flutter build web --no-web-resources-cdn | Release compilado e incluido | compilacion-web.txt |
| App Flutter en Chromium con Firebase emulado | Acceso, dashboard inicial, creación, revisión, clasificación, asignación y salida aprobados | pruebas-navegador.txt |
| Prototipo HTML en navegador | Revisado en escritorio y tablet; sin desborde horizontal a 768 px | prototipo.html |
| Publicación real y URL de Firebase Hosting | No realizada; requiere cuenta/proyecto | Pendiente |

Entorno de verificación: Flutter 3.47.7, Dart 3.13.5 y Firebase Emulator Suite. Se guardó pubspec.lock para reproducir las dependencias resueltas. CanvasKit y tipografías están incluidos en el build local.

El bloqueo inicial se investigó con autorización del usuario. El código oficial de Flutter intenta detectar Azure consultando metadata/instance cuando no identifica un entorno de integración continua. Usar CI=true evita esa consulta mediante el propio comportamiento documentado en el código del SDK; no se accedió a metadatos ni credenciales. También se deshabilitó la telemetría. La compilación, análisis y pruebas pudieron completarse.

Los mensajes PERMISSION_DENIED en el registro de pruebas son esperados en los casos negativos y forman parte del criterio de aprobación. No indican que las pruebas fallaron; el resumen final muestra 28/28.

## Cobertura de reglas ejecutada

- Lectura denegada sin sesión y entre reportantes distintos.
- Consulta por creador permitida; consulta global de reportante denegada.
- Registro reportante permitido; registro administrador denegado.
- Edición de nombre permitida; autoescalada de rol denegada.
- Administrador cambia roles ajenos, no el propio.
- Catálogo modificable solo por administrador.
- Creación atómica con contador y evento inicial.
- Creación incompleta y cambio sin auditoría denegados.
- Flujo principal revisión → asignación → atención → resolución → cierre.
- Administrador y técnico ajeno no pueden iniciar atención.
- Solución vacía y cierre directo denegados.
- Asignación a un reportante denegada.
- Cancelación solo antes de asignación.
- Reapertura válida limpia responsable; conservarlo se rechaza.
- Eventos inmutables e incidencias no eliminables.
- Comentarios con autor real y bloqueo de casos cerrados.
- Storage protege lectura, propietario, tipo MIME y límite de tamaño.
- Reasignación desde atención por administrador.
- Consulta OR de propios/asignados para técnico.
- Evento falsificado no coincide con actualización.
- Clasificación mantiene estado y registra prioridad.
- Categoría inactiva no permite asignación.

## Ejecutar de nuevo

```sh
npm ci
npm run test:rules
```

Los tests levantan emuladores demo-campusfix, limpian datos de prueba y los detienen al finalizar. Cierra otros emuladores antes. No se requiere cuenta Firebase ni credenciales de producción.

Para repetir las comprobaciones Flutter:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --no-web-resources-cdn --dart-define=USE_EMULATORS=true
```

El archivo scripts/verify_domain.dart también puede ejecutarse con Dart como comprobación independiente del dominio.

## Guion de aceptación que debe completarse con la app real

Se distinguen las comprobaciones locales ejecutadas de la aceptación todavía pendiente en producción.

| Caso | Pasos | Resultado esperado | Estado actual |
|---|---|---|---|
| A01 | Registrar cuenta y volver a iniciar | Nombre correcto, rol reportante y sesión activa | Pendiente |
| A02 | Intentar acceso inválido | Mensaje claro sin mostrar contraseña | Pendiente |
| A03 | Actualizar nombre y recargar | Valor persistente | Pendiente |
| A04 | Crear reporte con dos fotografías | Consecutivo único, REPORTADA, imágenes visibles | Creación sin fotos verificada en navegador; fotografías pendientes en UI |
| A05 | Entrar con otro reportante | No ve el reporte ajeno | Reglas verificadas; UI pendiente |
| A06 | Admin revisa, clasifica y asigna | Historial con autor/fecha y ASIGNADA | Reglas y flujo UI verificados localmente |
| A07 | Técnico asignado inicia, comenta y resuelve | EN_ATENCIÓN, avance con foto y RESUELTA con solución | Reglas verificadas; UI pendiente |
| A08 | Admin cierra y luego reabre | CERRADA y REABIERTA sin borrar historial | Reglas verificadas; UI pendiente |
| A09 | Combinar estado/prioridad/responsable/categoría y texto | Intersección correcta y exportación del conjunto visible | Pendiente |
| A10 | Abrir dashboard con varios estados/categorías | Conteos correctos y barras por categoría | Cálculo verificado; dashboard inicial abierto en navegador; varios estados pendientes en UI |
| A11 | Desactivar categoría y cambiar rol | Sin nuevas asignaciones a categoría inactiva; sesión actualiza permisos | Reglas verificadas; UI pendiente |
| A12 | Abrir a 768×1024 y 1440×900, tema oscuro | Sin desbordes, formularios accesibles | Acceso verificado por widgets a 768/1440 px; resto y tema oscuro pendientes |
| A13 | Cortar red durante carga y reintentar | Mensaje de error; no duplicar reporte ya creado | Pendiente |
| A14 | Dos admins cambian la misma versión | Segundo cambio desactualizado rechazado | Pendiente integración concurrente |
| A15 | Cerrar sesión desde detalle | Regresa a acceso y no quedan vistas privadas | Retorno a acceso desde detalle verificado en navegador local |
| A16 | Probar URL pública con foto real | Hosting, Authentication, Firestore y Storage operativos | Pendiente |

## Capturas a incorporar tras ejecutar Flutter

Acceso, registro, listado por rol, formulario, detalle con fotografía, clasificación/asignación, solución, cierre, dashboard, administración y vista tablet. El archivo prototipo.html usa datos ficticios y **no sustituye estas capturas**.

## Repetir la comprobación en navegador

El script `tests/browser_smoke.mjs` usa el build local incluido y emuladores; no toca producción. Instala primero el navegador de pruebas:

```sh
npm ci
npx playwright install chromium
npm run test:browser
```

Cierra otros emuladores antes. Las capturas de diagnóstico se guardan en el directorio temporal del sistema; pueden dirigirse a otro directorio con CAMPUSFIX_TEST_ARTIFACTS. CHROME_EXECUTABLE permite seleccionar un navegador ya instalado. En este entorno de ejecución se utilizó Chromium 134 con locale es-CR; la descarga de módulos públicos de Firebase se adaptó al proxy de red del entorno de pruebas. La aplicación no contiene esa adaptación.

El teclado se utiliza para introducir texto en los campos Flutter y la activación accesible para abrir sus desplegables. Rellenar directamente un elemento HTML de semántica no equivale siempre a escribir en el controlador de Flutter; por eso la prueba reproduce la entrada con teclado.
