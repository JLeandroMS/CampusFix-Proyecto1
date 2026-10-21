# Requisitos e historias de usuario

## Alcance y actores

CampusFix centraliza reportes, clasificación, asignación, atención, resolución, cierre y trazabilidad. La especificación base es `Proyecto_1_UCR.pdf`, IF0009, II Ciclo 2026. Este documento relaciona cada historia con el código; **implementación no equivale a aceptación ejecutada**. Consulte PRUEBAS.md para el estado de verificación.

| Actor | Operaciones |
|---|---|
| Reportante | Registrarse, editar nombre, crear reportes, ver los propios, comentar, adjuntar fotos, cancelar antes de asignación |
| Técnico | Crear y ver sus propios reportes, ver asignados, iniciar atención, registrar avances, resolver con explicación |
| Administrador | Ver todos, clasificar, asignar/reasignar, rechazar, cerrar resueltos, reabrir, gestionar roles/categorías y consultar indicadores |

## Trazabilidad de las 20 historias

| HU | Historia y criterio verificable | Implementación principal |
|---|---|---|
| 01 | Como usuario quiero registrarme e iniciar sesión. Credenciales válidas crean sesión y muestran el panel del rol. | AuthPage, AuthService.signIn/register, SessionGate |
| 02 | Como usuario quiero consultar/actualizar datos básicos. El nombre persiste entre sesiones; correo y rol son informativos. | ProfilePage, AuthService.updateName |
| 03 | Como administrador quiero asignar roles. El cliente y las reglas rechazan operaciones no autorizadas. | AdminPage, CatalogService.setRole, reglas users/incidents |
| 04 | Como usuario quiero cerrar sesión. Se destruye la vista privada y se vuelve al acceso. | AuthService.signOut, AuthState, SessionGate |
| 05 | Como usuario quiero crear una incidencia. Genera ID, consecutivo, fecha y estado REPORTADA. | IncidentFormPage, IncidentService.create, contador transaccional |
| 06 | Como usuario quiero adjuntar fotografías. Se cargan a Storage y se asocian mediante comentarios de evidencia. | EvidenceService.upload, IncidentService.comment |
| 07 | Como reportante quiero consultar mis reportes. La consulta y las reglas excluyen reportes ajenos. | IncidentService.watch, IncidentListPage |
| 08 | Como usuario quiero ver detalle e historial. Presenta responsables, estado, descripción, comentarios y eventos cronológicos. | IncidentDetailPage, events/comments |
| 09 | Como administrador quiero clasificar. Guarda categoría y prioridad con auditoría antes de asignar. | ChangeDialog, IncidentService.change |
| 10 | Como administrador quiero asignar un técnico. Valida el rol del responsable y cambia a ASIGNADA. | ChangeDialog, IncidentService.change, reglas technician |
| 11 | Como técnico quiero iniciar atención. Solo el técnico asignado pasa ASIGNADA a EN_ATENCIÓN. | IncidentPolicy y transition en reglas |
| 12 | Como técnico quiero registrar avances. Cada comentario contiene autor, fecha, texto y fotografía opcional. | IncidentDetailPage.post, IncidentService.comment |
| 13 | Como técnico quiero resolver. Exige solución de 10 a 2000 caracteres y cambia a RESUELTA. | ChangeDialog, IncidentPolicy.validate, reglas events |
| 14 | Como administrador quiero cerrar. Solo RESUELTA pasa a CERRADA. | IncidentPolicy, reglas transition |
| 15 | Como usuario autorizado quiero buscar. Busca consecutivo/texto y permite seleccionar categoría. | IncidentState.filtered, IncidentListPage |
| 16 | Como administrador quiero filtrar estado, prioridad y responsable. Los filtros combinan todas las condiciones. | IncidentState.filtered, filtros en listado |
| 17 | Como administrador quiero indicadores. Muestra total, abiertas, en atención, resueltas y cerradas. | DashboardState, DashboardPage |
| 18 | Como administrador quiero tendencias por categoría. Presenta conteos y barras proporcionales. | DashboardState.byCategory |
| 19 | Como administrador quiero auditar cambios. Eventos inmutables incluyen autor, fecha, estado y responsable; se guardan junto al cambio. | IncidentService.change, events, audited en reglas |
| 20 | Como equipo quiero publicar. Debe construirse y accederse desde Firebase Hosting. **Preparado, pendiente de despliegue y URL real.** | firebase.json, publicar.bat, DESPLIEGUE.md |

## Reglas de negocio y decisiones explícitas

El dibujo del enunciado dice REPORTAR; HU-05 exige REPORTADA. Se usa REPORTADA como estado inicial. En Firestore los nombres internos son `reportada`, `enRevision`, etc.; la interfaz muestra etiquetas españolas.

| Estado origen | Destino | Actor y condición |
|---|---|---|
| Reportada | En revisión | Administrador, motivo obligatorio |
| Reportada / En revisión / Reabierta | Rechazada | Administrador, motivo obligatorio |
| En revisión / Reabierta | Asignada | Administrador, categoría activa, prioridad válida, técnico válido |
| Asignada | En atención | Únicamente técnico asignado |
| En atención | Resuelta | Únicamente técnico asignado, solución obligatoria |
| Resuelta | Cerrada | Únicamente administrador |
| Reportada / En revisión | Cancelada | Únicamente creador |
| Resuelta / Cerrada | Reabierta | Administrador, motivo y responsable se limpia |
| Asignada / En atención | Asignada | Administrador, reasignación con motivo; el nuevo técnico debe iniciar atención |

Clasificar conserva estado y registra un evento en En revisión o Reabierta. Los rechazos/cancelaciones son terminales; no se eliminan datos históricos. Las reglas alternativas no detalladas en el enunciado son decisiones de diseño de esta implementación, no instrucciones adicionales del profesor.

Cada transición requiere motivo de 10 a 2000 caracteres. La prioridad inicial es media y el reportante sugiere una categoría. Antes de asignar, el administrador puede corregir categoría y prioridad; la asignación confirma los valores persistidos. Reabrir no borra eventos ni comentarios. Resuelta no se cuenta como abierta, y tampoco se confunde con Cerrada.

## Validaciones

- Nombre: 2–80 caracteres; título: 5–120; descripción: 10–3000; ubicación: 3–200.
- Comentario: 3–2000; motivo/solución: 10–2000; contraseña al registrar: mínimo 8 caracteres.
- Categorías de nuevos reportes y nuevas asignaciones deben estar activas.
- Prioridades: baja, media, alta, critica.
- Evidencias: JPEG/PNG, máximo 5 MiB por imagen. El registro inicial permite hasta cinco; el seguimiento una por comentario.
- Captura, carga, éxito, errores y estados vacíos se muestran sin dejar la pantalla en blanco.
- Los botones de envío se bloquean mientras la operación está en curso.
- El consecutivo no se calcula contando documentos: usa contador dentro de transacción.
- Un cambio desde una versión vieja exige volver a revisar el reporte.

## Requisitos no funcionales

Diseño Material 3 adaptable con menú lateral desde 1000 px y Drawer en anchos menores; formularios desplazables y filtros Wrap. Tema claro/oscuro. Autenticación obligatoria; autorización en Firebase; separación UI/estado/servicios/modelos; documentación Dart; commits reales y pipeline de comprobación.

Las pruebas de widgets de acceso en 768 y 1440 px pasaron. El análisis Flutter no reporta incidencias y el build Web se generó. Las pruebas de reglas validan permisos; consulte PRUEBAS.md para distinguirlas de las comprobaciones de interfaz y de la validación pendiente en producción.
