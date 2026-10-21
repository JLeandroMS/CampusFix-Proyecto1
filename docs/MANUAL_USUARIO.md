# Manual breve de usuario

## Ingreso y perfil

1. Abre la dirección publicada por tu equipo o inicia la versión local según INICIAR_AQUI.md.
2. Para una cuenta nueva, selecciona Registrarme como reportante y completa nombre, correo y contraseña de al menos ocho caracteres.
3. Ingresa con tus credenciales. Si olvidaste la contraseña, escribe tu correo y pulsa Olvidé mi contraseña. En emuladores, el enlace aparece en el registro del emulador; no se envía un correo real.
4. En Mi perfil puedes cambiar tu nombre. El rol lo administra una persona autorizada.
5. Usa el icono de contraste para cambiar tema. Se conserva al volver al navegador.
6. Usa Cerrar sesión al terminar. Se vuelve a la pantalla de acceso.

## Reportante: crear y consultar

Pulsa Nueva incidencia. Completa título descriptivo, explicación, ubicación y categoría. Puedes seleccionar hasta cinco fotos PNG/JPEG, cada una de hasta 5 MiB. Pulsa Enviar reporte una sola vez y espera la confirmación.

El sistema asigna un número CF-000001 y estado REPORTADA. La categoría es una propuesta inicial y la prioridad se crea como media; administración las revisa.

En Incidencias aparecen tus reportes. Busca parte del título, descripción o consecutivo; combina categoría, estado y prioridad. Abre una tarjeta para consultar estado, responsable, comentarios e historial.

Para añadir contexto, escribe un comentario, adjunta una foto opcional y pulsa Publicar seguimiento. Cargar una fotografía no la asocia hasta publicar el comentario. Si falla la operación, permanece disponible para reintentar. No cierres la vista durante el envío.

Puedes cancelar tu reporte mientras esté REPORTADA o EN_REVISIÓN, indicando un motivo. No se borran sus datos. Los casos cerrados, rechazados o cancelados no admiten más comentarios.

## Administrador: revisar y asignar

1. Abre un caso reportado y pulsa Revisar; describe el motivo del cambio.
2. Pulsa Clasificar en estado EN_REVISIÓN: revisa categoría y prioridad y guarda.
3. Pulsa Asignar técnico, selecciona un usuario con rol técnico y explica la asignación.
4. El estado cambia a ASIGNADA. Si no hay técnicos, asigna ese rol a una cuenta registrada en Administración.
5. Un caso ASIGNADA o EN_ATENCIÓN puede reasignarse. Vuelve a ASIGNADA y el nuevo técnico debe iniciar atención.
6. Puedes rechazar un caso reportado, en revisión o reabierto justificando la decisión.

Para reasignar por baja o cambio de rol, abre primero el caso y elige otro técnico. Si el rol anterior ya cambió, el administrador todavía puede reasignar el caso.

## Técnico: atención y solución

En la bandeja se muestran tus casos asignados y los reportes que creaste. Solo puedes iniciar los que te asignaron. Abre uno en ASIGNADA y pulsa Iniciar atención. Registra avances con comentarios y fotografías.

Al completar el trabajo, pulsa Registrar solución y escribe una explicación de 10 a 2000 caracteres. El caso queda RESUELTA; un administrador debe formalizar el cierre. No intentes iniciar casos de otro técnico, cambiar clasificación ni cerrar directamente.

## Administrador: cerrar o reabrir

En un caso RESUELTA, pulsa Cerrar caso y documenta la revisión. Solo este estado permite CERRADA.

Si el problema continúa, puedes reabrir desde RESUELTA o CERRADA. El historial permanece, el responsable se limpia y el caso vuelve al proceso de clasificación/asignación. Reabrir requiere motivo.

## Dashboard, catálogos y roles

Dashboard muestra total, abiertas, en atención, resueltas y cerradas; abajo presenta conteos por categoría. Los indicadores son de todas las incidencias, independientes de filtros del listado.

En Administración crea categorías, renómbralas o desactívalas. Desactivar impide usarlas en nuevos reportes/asignaciones, pero mantiene referencias históricas. Si no existen categorías activas, no se puede crear una incidencia.

En Usuarios y roles selecciona el nuevo rol y confirma. No puedes cambiar tu propio rol. Las reglas del servidor verifican permisos incluso si alguien altera la interfaz.

## Exportación y errores

Exportar JSON descarga únicamente los reportes visibles tras filtros. No incluye contraseñas, tokens ni binarios de fotografías.

Si el sistema indica que un reporte cambió, vuelve al listado y revisa la versión actual. Si una fotografía falla tras crear el reporte, no lo vuelvas a crear: abre el detalle y adjúntala allí. Si una imagen no carga en producción, el responsable técnico debe comprobar permisos y CORS según DESPLIEGUE.md.
