# Entrega del proyecto CampusFix

Universidad de Costa Rica — Sede del Sur  
Curso: IF0009 Desarrollo de Software IV  
Proyecto: CampusFix — Gestión de incidencias del campus  
Fecha: 22 de octubre de 2026

## Integrantes

- Leandro Marin C5G787
- Steven Ramirez C6I706
- Hugo Gurdian C5F739

## Enlaces

- Aplicación publicada: https://campusfix-19d22.web.app
- Repositorio: [Agregar enlace de GitHub]

## Descripción

CampusFix es una aplicación web para registrar y gestionar incidencias
relacionadas con infraestructura, conectividad, mobiliario, iluminación,
limpieza, accesibilidad y equipos del campus universitario.

Permite dar seguimiento a cada incidencia desde su registro hasta su
resolución y cierre, conservando fotografías, comentarios e historial
de cambios.

## Tecnologías utilizadas

- Flutter Web y Dart para la aplicación.
- Provider y ChangeNotifier para el manejo de estado.
- Firebase Authentication para el registro e inicio de sesión.
- Cloud Firestore para almacenar los datos.
- Cloud Storage para almacenar fotografías y evidencias.
- Firebase Hosting para publicar la aplicación.
- Reglas de seguridad de Firestore y Storage para controlar el acceso.
- Git para el control de versiones.

El código se organiza en capas de interfaz, estado, servicios y modelos,
con documentación de sus responsabilidades y métodos principales.

## Funcionalidades implementadas

### Reportante

- Registrarse e iniciar sesión.
- Crear incidencias con descripción, ubicación y categoría.
- Adjuntar fotografías.
- Consultar sus reportes, estados e historial.
- Agregar comentarios de seguimiento cuando el estado lo permite.

### Técnico

- Consultar las incidencias asignadas.
- Iniciar la atención de una incidencia.
- Registrar avances y evidencias.
- Registrar la solución y marcar la incidencia como resuelta.

### Administrador

- Revisar y clasificar incidencias.
- Establecer prioridades y asignar técnicos.
- Cerrar incidencias resueltas.
- Gestionar categorías y roles.
- Consultar indicadores, filtrar incidencias y exportar resultados.

### Control del proceso

- Validación de transiciones entre estados según el rol.
- Historial de cambios con autor y fecha.
- Control de acceso a datos y fotografías.
- Validación de formularios, archivos y operaciones.
- Manejo de estados de carga y mensajes de error.

## Despliegue

La aplicación se encuentra publicada en Firebase Hosting y conectada
al proyecto Firebase `campusfix-19d22`.

Se habilitaron Authentication, Cloud Firestore y Cloud Storage.
Las reglas de seguridad y los índices de Firestore se desplegaron
correctamente. También se configuró CORS para visualizar las
fotografías desde los dominios de la aplicación.

Se configuró una cuenta administradora, una cuenta técnica y las
categorías de incidencias.

La versión publicada utiliza servicios reales de Firebase.
Los emuladores se emplean exclusivamente para desarrollo y pruebas locales.

## Verificación realizada

| Comprobación | Resultado |
|---|---|
| Análisis estático de Flutter | Sin incidencias |
| Pruebas unitarias y de widgets de Flutter | 8 aprobadas |
| Pruebas de reglas de Firestore y Storage en emuladores | 28 aprobadas |
| Comprobaciones independientes del dominio | 12 aprobadas |
| Compilación web de producción | Completada |
| Publicación de reglas e índices en Firebase | Completada |
| Publicación en Firebase Hosting | Completada |
| Registro y acceso a la administración en producción | Confirmados por el equipo |
| Creación de reporte con fotografía y visualización después de recargar | Confirmadas por el equipo |

También se verificó en navegador con emuladores el acceso, la apertura
del dashboard, la creación de una incidencia, su revisión,
clasificación, asignación y el cierre de sesión.

Los registros y el alcance de las pruebas automatizadas se encuentran
en `docs/PRUEBAS.md` y en los archivos de resultados de la carpeta `docs`.

## Documentación incluida

| Archivo | Contenido |
|---|---|
| `README.md` | Descripción general y estructura del proyecto |
| `INICIAR_AQUI.md` | Instrucciones de ejecución local |
| `docs/REQUISITOS.md` | Trazabilidad de historias y requisitos |
| `docs/ARQUITECTURA.md` | Arquitectura y modelo de datos |
| `docs/MANUAL_USUARIO.md` | Instrucciones de uso por rol |
| `docs/DESPLIEGUE.md` | Configuración, publicación y repositorio |
| `docs/PRUEBAS.md` | Resultados y guion de aceptación |
| `docs/prototipo.html` | Prototipo visual de referencia |

## Acceso y roles

Los usuarios pueden registrarse desde la aplicación y reciben
inicialmente el rol de reportante.

El administrador asigna el rol de técnico a las cuentas que corresponda.
Las credenciales de las cuentas utilizadas para la evaluación se
facilitan al docente por el medio privado acordado.

Las cuentas de demostración con dominio `@campusfix.test` pertenecen
únicamente a los emuladores y no corresponden al entorno publicado.