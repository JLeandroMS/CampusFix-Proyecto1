import 'domain.dart';

/// Reglas de negocio puras, compartidas por estado/UI y pruebas unitarias.
/// Firestore vuelve a validarlas: ocultar botones NO es autorización.
class IncidentPolicy {
  static List<IncidentStatus> allowed(Incident i, UserProfile u) {
    final s = i.status;
    final result = <IncidentStatus>[];
    if (u.role == UserRole.administrador) {
      result.addAll(switch (s) {
        IncidentStatus.reportada => [
          IncidentStatus.enRevision,
          IncidentStatus.rechazada,
        ],
        IncidentStatus.enRevision => [
          IncidentStatus.asignada,
          IncidentStatus.rechazada,
        ],
        IncidentStatus.reabierta => [
          IncidentStatus.asignada,
          IncidentStatus.rechazada,
        ],
        IncidentStatus.asignada ||
        IncidentStatus.enAtencion => [IncidentStatus.asignada],
        IncidentStatus.resuelta => [
          IncidentStatus.cerrada,
          IncidentStatus.reabierta,
        ],
        IncidentStatus.cerrada => [IncidentStatus.reabierta],
        _ => <IncidentStatus>[],
      });
    }
    if (u.role == UserRole.tecnico && i.technicianId == u.id) {
      if (s == IncidentStatus.asignada) result.add(IncidentStatus.enAtencion);
      if (s == IncidentStatus.enAtencion) result.add(IncidentStatus.resuelta);
    }
    if (i.creatorId == u.id &&
        [IncidentStatus.reportada, IncidentStatus.enRevision].contains(s)) {
      result.add(IncidentStatus.cancelada);
    }
    return result;
  }

  /// Toda transición deja motivo; resolución exige una solución significativa.
  static void validate(
    Incident i,
    UserProfile u,
    IncidentStatus target,
    String note,
  ) {
    if (!allowed(i, u).contains(target))
      throw StateError('Transición no autorizada.');
    if (note.trim().length < 10 || note.trim().length > 2000) {
      throw ArgumentError(
        'Escriba un motivo o solución de 10 a 2000 caracteres.',
      );
    }
  }
}
