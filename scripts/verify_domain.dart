// Script CLI independiente: imprime resultados e importa el dominio sin pub.
// ignore_for_file: avoid_print, avoid_relative_lib_imports
// Verificación local de negocio sin Flutter, sin Firebase y sin red.
import '../lib/models/domain.dart';
import '../lib/models/incident_policy.dart';
import '../lib/state/dashboard_state.dart';

void main() {
  var checks = 0;
  void check(bool ok, String message) {
    if (!ok) throw StateError(message);
    checks++;
    print('PASS: $message');
  }

  const admin = UserProfile(
    'a',
    'Admin',
    'a@example.com',
    UserRole.administrador,
  );
  const tech = UserProfile('t', 'Técnico', 't@example.com', UserRole.tecnico);
  const user = UserProfile(
    'u',
    'Usuario',
    'u@example.com',
    UserRole.reportante,
  );
  Incident at(IncidentStatus s) => Incident(
    id: 'i',
    number: 23,
    title: 'Falla',
    description: 'Descripción',
    categoryId: 'luz',
    location: 'Aula',
    creatorId: 'u',
    technicianId: 't',
    priority: 'media',
    status: s,
    revision: 0,
  );
  check(
    at(IncidentStatus.reportada).code == 'CF-000023',
    'consecutivo con ceros',
  );
  check(
    IncidentPolicy.allowed(
      at(IncidentStatus.asignada),
      tech,
    ).contains(IncidentStatus.enAtencion),
    'técnico asignado inicia',
  );
  check(
    !IncidentPolicy.allowed(
      at(IncidentStatus.asignada),
      admin,
    ).contains(IncidentStatus.enAtencion),
    'admin no inicia atención',
  );
  check(
    !IncidentPolicy.allowed(
      at(IncidentStatus.reportada),
      admin,
    ).contains(IncidentStatus.cerrada),
    'no salta al cierre',
  );
  check(
    IncidentPolicy.allowed(
      at(IncidentStatus.resuelta),
      admin,
    ).contains(IncidentStatus.cerrada),
    'admin cierra resuelta',
  );
  check(
    IncidentPolicy.allowed(
      at(IncidentStatus.reportada),
      user,
    ).contains(IncidentStatus.cancelada),
    'creador cancela reportada',
  );
  check(
    !IncidentPolicy.allowed(
      at(IncidentStatus.asignada),
      user,
    ).contains(IncidentStatus.cancelada),
    'no cancela asignada',
  );
  check(
    IncidentPolicy.allowed(
      at(IncidentStatus.cerrada),
      admin,
    ).contains(IncidentStatus.reabierta),
    'admin reabre cerrada',
  );
  check(
    IncidentPolicy.allowed(
      at(IncidentStatus.enAtencion),
      admin,
    ).contains(IncidentStatus.asignada),
    'admin reasigna',
  );
  bool invalid = false;
  try {
    IncidentPolicy.validate(
      at(IncidentStatus.enAtencion),
      tech,
      IncidentStatus.resuelta,
      '',
    );
  } on ArgumentError {
    invalid = true;
  }
  check(invalid, 'solución vacía rechazada');
  final summary = DashboardState(IncidentStatus.values.map(at).toList());
  check(summary.total == 9 && summary.open == 5, 'total y abiertas');
  check(summary.byCategory['luz'] == 9, 'agregación por categoría');
  print('$checks comprobaciones completadas.');
}
