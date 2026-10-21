/// Roles persistidos en Firestore. El registro público siempre crea reportantes.
enum UserRole { reportante, tecnico, administrador }

/// Contrato de estados del proceso; REPORTADA es el resultado de REPORTAR.
enum IncidentStatus {
  reportada, enRevision, asignada, enAtencion, resuelta, cerrada,
  rechazada, cancelada, reabierta;

  String get label => const {
    reportada: 'REPORTADA', enRevision: 'EN_REVISIÓN', asignada: 'ASIGNADA',
    enAtencion: 'EN_ATENCIÓN', resuelta: 'RESUELTA', cerrada: 'CERRADA',
    rechazada: 'RECHAZADA', cancelada: 'CANCELADA', reabierta: 'REABIERTA',
  }[this]!;
  bool get isOpen => !{resuelta, cerrada, rechazada, cancelada}.contains(this);
}

/// Perfil sin contraseñas ni tokens. La identidad procede de Authentication.
class UserProfile {
  final String id, name, email;
  final UserRole role;
  const UserProfile(this.id, this.name, this.email, this.role);
  factory UserProfile.fromMap(String id, Map<String, dynamic> map) => UserProfile(
    id, map['name'] as String, map['email'] as String,
    UserRole.values.byName(map['role'] as String),
  );
}

/// Catálogo desactivable: conserva la interpretación de reportes históricos.
class Category {
  final String id, name;
  final bool active;
  const Category(this.id, this.name, this.active);
  factory Category.fromMap(String id, Map<String, dynamic> map) =>
      Category(id, map['name'] as String, map['active'] as bool);
}

/// Incidencia inmutable. Comentarios, fotos y auditoría son subcolecciones
/// para evitar listas ilimitadas y el límite de tamaño de un documento.
class Incident {
  final String id, title, description, categoryId, location, creatorId;
  final String? technicianId;
  final int number, revision;
  final String priority;
  final IncidentStatus status;
  final DateTime? createdAt, updatedAt;
  const Incident({required this.id, required this.number, required this.title,
    required this.description, required this.categoryId, required this.location,
    required this.creatorId, required this.technicianId, required this.priority,
    required this.status, required this.revision, this.createdAt, this.updatedAt});
  String get code => 'CF-${number.toString().padLeft(6, '0')}';
  factory Incident.fromMap(String id, Map<String, dynamic> m) => Incident(
    id: id, number: m['number'] as int, title: m['title'] as String,
    description: m['description'] as String, categoryId: m['categoryId'] as String,
    location: m['location'] as String, creatorId: m['creatorId'] as String,
    technicianId: m['technicianId'] as String?, priority: m['priority'] as String,
    status: IncidentStatus.values.byName(m['status'] as String),
    revision: m['revision'] as int,
    createdAt: m['createdAt']?.toDate() as DateTime?,
    updatedAt: m['updatedAt']?.toDate() as DateTime?,
  );
}
