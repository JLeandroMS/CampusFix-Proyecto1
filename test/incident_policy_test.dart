import 'package:flutter_test/flutter_test.dart';
import 'package:campusfix/models/domain.dart';
import 'package:campusfix/models/incident_policy.dart';
import 'package:campusfix/state/dashboard_state.dart';

Incident report(IncidentStatus status, {String? tech}) => Incident(
  id: 'a',
  number: 1,
  title: 'Falla de luz',
  description: 'No enciende la lámpara',
  categoryId: 'luz',
  location: 'Aula 1',
  creatorId: 'r',
  technicianId: tech,
  priority: 'media',
  status: status,
  revision: 0,
);
const admin = UserProfile(
  'a',
  'Admin',
  'a@example.com',
  UserRole.administrador,
);
const tech = UserProfile('t', 'Técnico', 't@example.com', UserRole.tecnico);
const reporter = UserProfile(
  'r',
  'Usuario',
  'r@example.com',
  UserRole.reportante,
);
void main() {
  test('solo técnico asignado inicia atención', () {
    final i = report(IncidentStatus.asignada, tech: 't');
    expect(
      IncidentPolicy.allowed(i, tech),
      contains(IncidentStatus.enAtencion),
    );
    expect(
      IncidentPolicy.allowed(i, admin),
      isNot(contains(IncidentStatus.enAtencion)),
    );
    expect(
      IncidentPolicy.allowed(
        report(IncidentStatus.asignada, tech: 'otro'),
        tech,
      ),
      isEmpty,
    );
  });
  test('resolución requiere explicación', () {
    expect(
      () => IncidentPolicy.validate(
        report(IncidentStatus.enAtencion, tech: 't'),
        tech,
        IncidentStatus.resuelta,
        '',
      ),
      throwsArgumentError,
    );
  });
  test('cierre exige caso resuelto y administrador', () {
    expect(
      IncidentPolicy.allowed(report(IncidentStatus.reportada), admin),
      isNot(contains(IncidentStatus.cerrada)),
    );
    expect(
      IncidentPolicy.allowed(report(IncidentStatus.resuelta), admin),
      contains(IncidentStatus.cerrada),
    );
    expect(
      IncidentPolicy.allowed(report(IncidentStatus.resuelta), reporter),
      isEmpty,
    );
  });
  test('cancelación solo antes de asignar', () {
    expect(
      IncidentPolicy.allowed(report(IncidentStatus.reportada), reporter),
      contains(IncidentStatus.cancelada),
    );
    expect(
      IncidentPolicy.allowed(report(IncidentStatus.asignada), reporter),
      isEmpty,
    );
  });
  test('dashboard no considera terminales como abiertas', () {
    final d = DashboardState(IncidentStatus.values.map(report).toList());
    expect(d.total, 9);
    expect(d.open, 5);
    expect(d.count(IncidentStatus.resuelta), 1);
    expect(d.byCategory['luz'], 9);
  });
  test('consecutivo legible', () {
    expect(report(IncidentStatus.reportada).code, 'CF-000001');
  });
}
