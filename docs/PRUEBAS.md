# Evidencia de pruebas y pendientes

Fecha de ejecución: 20 de octubre de 2026 (Costa Rica).

## Resultados ejecutados

| Comprobación | Resultado real | Evidencia |
|---|---|---|
| Reglas Firestore y Storage en emuladores | 28 aprobadas, 0 fallidas | pruebas-reglas.txt |
| Lógica Dart independiente, sin Flutter ni red | 12 aprobadas | pruebas-dominio.txt |
| Parseo y formato de código Dart | 25 archivos procesados; sin errores sintácticos | formato-dart.txt |
| flutter analyze | No ejecutado hasta completar; bloqueado al preparar SDK | Pendiente |
| flutter test (unitarias y widgets) | Escritas, no ejecutadas | test/ |
| flutter build web | No ejecutado | Pendiente |
| Prueba visual de app Flutter | No ejecutada | Pendiente |
| Revisión del prototipo HTML en navegador | Pendiente; la descarga del navegador de pruebas falló | prototipo.html |
| Publicación real y URL de Firebase Hosting | No realizada; requiere cuenta/proyecto | Pendiente |

El formateador advirtió que flutter_lints no estaba resuelto porque no se completó la preparación de dependencias. Parsear y formatear no verifica tipos, compatibilidad de paquetes, renderizado ni integración completa.

La revisión automática de ejecución bloqueó el arranque de Flutter por un intento de acceso al servicio de metadatos de nube, una frontera sensible de credenciales. Se detuvo el proceso pendiente de preparación y no se reintentó ese acceso. La verificación Dart independiente ejecutó únicamente modelos y políticas locales.

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

Cuando Flutter esté disponible:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define=USE_EMULATORS=true
```

El archivo scripts/verify_domain.dart también puede ejecutarse con Dart como comprobación independiente del dominio.

## Guion de aceptación que debe completarse con la app real

Registra resultado, fecha y captura en cada fila. Los resultados no están prellenados para evitar inventar evidencia.

| Caso | Pasos | Resultado esperado | Estado actual |
|---|---|---|---|
| A01 | Registrar cuenta y volver a iniciar | Nombre correcto, rol reportante y sesión activa | Pendiente |
| A02 | Intentar acceso inválido | Mensaje claro sin mostrar contraseña | Pendiente |
| A03 | Actualizar nombre y recargar | Valor persistente | Pendiente |
| A04 | Crear reporte con dos fotografías | Consecutivo único, REPORTADA, imágenes visibles | Pendiente |
| A05 | Entrar con otro reportante | No ve el reporte ajeno | Reglas verificadas; UI pendiente |
| A06 | Admin revisa, clasifica y asigna | Historial con autor/fecha y ASIGNADA | Reglas verificadas; UI pendiente |
| A07 | Técnico asignado inicia, comenta y resuelve | EN_ATENCIÓN, avance con foto y RESUELTA con solución | Reglas verificadas; UI pendiente |
| A08 | Admin cierra y luego reabre | CERRADA y REABIERTA sin borrar historial | Reglas verificadas; UI pendiente |
| A09 | Combinar estado/prioridad/responsable/categoría y texto | Intersección correcta y exportación del conjunto visible | Pendiente |
| A10 | Abrir dashboard con varios estados/categorías | Conteos correctos y barras por categoría | Cálculo verificado; UI pendiente |
| A11 | Desactivar categoría y cambiar rol | Sin nuevas asignaciones a categoría inactiva; sesión actualiza permisos | Reglas verificadas; UI pendiente |
| A12 | Abrir a 768×1024 y 1440×900, tema oscuro | Sin desbordes, formularios accesibles | Pendiente |
| A13 | Cortar red durante carga y reintentar | Mensaje de error; no duplicar reporte ya creado | Pendiente |
| A14 | Dos admins cambian la misma versión | Segundo cambio desactualizado rechazado | Pendiente integración concurrente |
| A15 | Cerrar sesión desde detalle | Regresa a acceso y no quedan vistas privadas | Pendiente |
| A16 | Probar URL pública con foto real | Hosting, Authentication, Firestore y Storage operativos | Pendiente |

## Capturas a incorporar tras ejecutar Flutter

Acceso, registro, listado por rol, formulario, detalle con fotografía, clasificación/asignación, solución, cierre, dashboard, administración y vista tablet. El archivo prototipo.html usa datos ficticios y **no sustituye estas capturas**.
