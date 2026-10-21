# CampusFix

Aplicación Flutter Web para reportar, clasificar, asignar y seguir incidencias del campus. Proyecto Integrador 1 de IF0009, Universidad de Costa Rica, Sede del Sur.

**Empieza por [INICIAR_AQUI.md](INICIAR_AQUI.md).** La aplicación compila para Web, el análisis Flutter no reporta incidencias y las 8 pruebas Flutter pasan. El ZIP incluye un build para emuladores locales. El despliegue real sigue pendiente de conectar el Firebase del equipo.

## Tecnologías y responsabilidades

| Capa | Archivos | Responsabilidad |
|---|---|---|
| Composición | `lib/main.dart` | Inicializar Firebase, seleccionar emuladores, inyectar dependencias y tema |
| Modelos | `lib/models/domain.dart` | Perfil, rol, categoría, incidencia y estados |
| Negocio | `lib/models/incident_policy.dart` | Transiciones según rol, asignación y explicación obligatoria |
| Autenticación | `lib/services/auth_service.dart` | Registro, sesión, recuperación, perfil y cierre |
| Datos | `lib/services/incident_service.dart` | Consultas autorizadas, transacciones, consecutivo y auditoría |
| Catálogos | `lib/services/catalog_service.dart` | Categorías activas/inactivas y roles |
| Evidencias | `lib/services/evidence_service.dart` | Selección, validación, carga y descarga privada de imágenes |
| Exportación | `lib/services/export_service.dart` | Descargar los reportes visibles como JSON |
| Estado | `lib/state/*` | AuthState, IncidentState, IncidentFormState, DashboardState y ThemeState |
| UI | `lib/ui/*` | Formularios, navegación, detalle, historial, dashboard y administración |
| Seguridad | `firestore.rules`, `storage.rules` | Autorizar operaciones incluso fuera de la interfaz |
| Pruebas | `test/*`, `tests/*`, `scripts/verify_domain.dart` | Negocio, widgets, reglas Firestore/Storage y verificación Dart independiente |

Provider distribuye servicios y ChangeNotifier notifica cambios. DashboardState calcula una proyección pura a partir de IncidentState. El estado del formulario se llama IncidentFormState para no confundirse con FormState de Flutter.

## Flujo

REPORTADA → EN_REVISIÓN → ASIGNADA → EN_ATENCIÓN → RESUELTA → CERRADA.

El administrador clasifica y asigna; solo el técnico asignado inicia y resuelve; solo el administrador cierra. Rechazo, cancelación y reapertura tienen reglas explícitas en `docs/REQUISITOS.md`.

## Datos y seguridad

Authentication gestiona credenciales. Firestore guarda usuarios, categorías, incidencias, comentarios y eventos; Storage guarda imágenes. SharedPreferences solo guarda tema. No existe un servidor Node para negocio ni una base SQLite: se usa el backend administrado de Firebase pedido por el enunciado.

No se almacenan contraseñas, tokens ni URLs públicas de descarga en Firestore. Una operación de incidencia y su auditoría se escriben atómicamente y llevan fecha del servidor. El consecutivo se reserva mediante transacción. Los documentos de auditoría no pueden editarse ni borrarse desde clientes.

Los listados hacen suscripciones en tiempo real. Filtros y búsqueda se aplican sobre el conjunto que el usuario está autorizado a leer. Esta decisión es adecuada para el volumen académico; para uso masivo requeriría paginación, métricas agregadas e indexación de búsqueda.

## Documentación y pruebas

- [Requisitos e historias](docs/REQUISITOS.md)
- [Arquitectura y modelo](docs/ARQUITECTURA.md)
- [Manual de usuario](docs/MANUAL_USUARIO.md)
- [Pruebas y evidencia](docs/PRUEBAS.md)
- [Despliegue](docs/DESPLIEGUE.md)
- [Lista de entrega](docs/ENTREGA.md)

## Fuentes de implementación

Enunciado `Proyecto_1_UCR.pdf` aportado por el usuario. Los laboratorios adjuntos sirven de contexto sobre separación de responsabilidades, formularios, JSON y persistencia; no reemplazan los requisitos Firebase de este proyecto.

Documentación oficial consultada el 20 de octubre de 2026:

- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/firestore/manage-data/transactions
- https://firebase.google.com/docs/storage/flutter/download-files
- https://firebase.google.com/docs/storage/web/download-files

No se agregan credenciales de ejemplo a producción. Los datos ficticios del prototipo y las cuentas de emulador están identificados como demostración.
