# CampusFix

**Sistema web de gestión de incidencias del campus universitario**  
Universidad de Costa Rica — Sede del Sur  
Curso: IF0009 Desarrollo de Software IV — Proyecto Integrador 1  
**Fecha de entrega:** 22 de octubre de 2026

## Acceso a la aplicación

**Aplicación publicada:** https://campusfix-19d22.web.app  
**Repositorio:** https://github.com/JLeandroMS/CampusFix-Proyecto1

CampusFix permite reportar incidencias de infraestructura, conectividad, mobiliario, iluminación, limpieza, accesibilidad y equipos del campus. Cada reporte puede incluir ubicación, categoría, descripción, fotografías, comentarios e historial de cambios, desde su registro hasta su cierre.

## Integrantes

- Leandro Marin — C5G787
- Steven Ramirez — C6I706
- Hugo Gurdian — C5F739

## Tecnologías

- **Flutter Web / Dart:** interfaz web y lógica de la aplicación.
- **Provider / ChangeNotifier:** gestión y actualización del estado.
- **Firebase Authentication:** registro e inicio de sesión.
- **Cloud Firestore:** usuarios, categorías, incidencias, comentarios y auditoría.
- **Cloud Storage:** fotografías y evidencias.
- **Firebase Hosting:** publicación de la aplicación.
- **Reglas de Firestore y Storage:** control de permisos y acceso.
- **Git / GitHub:** control de versiones y repositorio.

No se utiliza un servidor Node.js ni SQLite para la lógica principal: los servicios de backend se proporcionan mediante Firebase. `SharedPreferences` se emplea para guardar la preferencia del tema visual.

## Funcionalidades por rol

| Rol | Funcionalidades |
|---|---|
| **Reportante** | Registrarse, iniciar sesión, crear incidencias, adjuntar imágenes, consultar sus reportes e historial y comentar cuando el estado lo permita. |
| **Técnico** | Consultar incidencias asignadas, iniciar su atención, registrar avances y evidencias y marcar la resolución. |
| **Administrador** | Revisar y clasificar incidencias, asignar prioridades y técnicos, cerrar incidencias, administrar categorías y roles, consultar indicadores, filtrar y exportar resultados. |

### Ciclo de vida de una incidencia

`REPORTADA → EN_REVISIÓN → ASIGNADA → EN_ATENCIÓN → RESUELTA → CERRADA`

Las transiciones se validan según el rol. También existen reglas para rechazo, cancelación y reapertura, documentadas en [`docs/REQUISITOS.md`](docs/REQUISITOS.md). Los cambios guardan autor y fecha en el historial.

## Arquitectura del código

| Capa | Ubicación | Responsabilidad |
|---|---|---|
| Composición | `lib/main.dart` | Inicialización de Firebase, configuración e inyección de dependencias. |
| Modelos | `lib/models/domain.dart` | Entidades, roles y estados. |
| Reglas del negocio | `lib/models/incident_policy.dart` | Validación de cambios de estado y asignaciones. |
| Autenticación | `lib/services/auth_service.dart` | Sesiones, registro y perfiles. |
| Incidencias | `lib/services/incident_service.dart` | Consultas, transacciones, numeración y auditoría. |
| Catálogos | `lib/services/catalog_service.dart` | Categorías y roles. |
| Evidencias | `lib/services/evidence_service.dart` | Validación y gestión de fotografías. |
| Exportación | `lib/services/export_service.dart` | Exportación de reportes visibles a JSON. |
| Estado | `lib/state/` | Gestión de estados con Provider y ChangeNotifier. |
| Interfaz | `lib/ui/` | Pantallas, formularios, paneles y navegación. |
| Seguridad | `firestore.rules`, `storage.rules` | Permisos para datos y archivos. |
| Pruebas | `test/`, `tests/`, `scripts/verify_domain.dart` | Verificaciones automatizadas. |

## Despliegue y seguridad

La aplicación **ya está publicada en Firebase Hosting** y conectada al proyecto Firebase `campusfix-19d22`, utilizando los servicios reales de Authentication, Cloud Firestore y Cloud Storage.

Se desplegaron las reglas de seguridad y los índices de Firestore; también se configuró CORS para mostrar fotografías desde los dominios de la aplicación. Se configuraron cuentas de administración y atención técnica y las categorías de incidencias.

Las pruebas locales pueden emplear emuladores de Firebase, pero **el sitio publicado usa los servicios reales**. Las cuentas con dominio `@campusfix.test` corresponden únicamente a los emuladores.

### Cuentas de acceso para evaluación

| Rol | Correo electrónico | Contraseña |
|---|---|---|
| **Administrador** | `admin@campusfix.com` | `admin123!` |
| **Técnico** | `tecnico@campusfix.com` | `tecnico123!` |

> Estas credenciales están incluidas para la evaluación académica. Deben cambiarse o deshabilitarse al finalizar la evaluación si el repositorio es público.

## Pruebas y verificaciones

| Verificación | Resultado |
|---|---|
| Análisis estático de Flutter | Sin incidencias |
| Pruebas unitarias y de widgets | 8 aprobadas |
| Pruebas de reglas de Firestore y Storage en emuladores | 28 aprobadas |
| Comprobaciones independientes del dominio | 12 aprobadas |
| Compilación web de producción | Completada |
| Publicación de reglas e índices | Completada |
| Publicación en Firebase Hosting | Completada |
| Acceso de administrador en producción | Confirmado por el equipo |
| Creación y persistencia de un reporte con fotografía | Confirmadas por el equipo |

Las evidencias, el alcance de las pruebas y el procedimiento de aceptación están en [`docs/PRUEBAS.md`](docs/PRUEBAS.md).

## Ejecución local

Para preparar el entorno de desarrollo se requieren Flutter y la configuración correspondiente de Firebase. Consulta **[`INICIAR_AQUI.md`](INICIAR_AQUI.md)** para los pasos detallados de ejecución, incluyendo el uso de emuladores cuando corresponda.

## Documentación

- [`INICIAR_AQUI.md`](INICIAR_AQUI.md) — Inicio y ejecución local.
- [`docs/REQUISITOS.md`](docs/REQUISITOS.md) — Requisitos, historias y reglas del negocio.
- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — Arquitectura y modelo de datos.
- [`docs/MANUAL_USUARIO.md`](docs/MANUAL_USUARIO.md) — Uso de la aplicación por rol.
- [`docs/DESPLIEGUE.md`](docs/DESPLIEGUE.md) — Configuración y publicación.
- [`docs/PRUEBAS.md`](docs/PRUEBAS.md) — Resultados y evidencias de pruebas.
- [`docs/ENTREGA.md`](docs/ENTREGA.md) — Resumen final de entrega.
- [`docs/prototipo.html`](docs/prototipo.html) — Prototipo visual.

## Referencias técnicas

- [Configuración de Firebase en Flutter](https://firebase.google.com/docs/flutter/setup)
- [Transacciones de Cloud Firestore](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [Descarga de archivos con Cloud Storage para Flutter](https://firebase.google.com/docs/storage/flutter/download-files)

---

**CampusFix — Proyecto Integrador 1, Universidad de Costa Rica, Sede del Sur.**
