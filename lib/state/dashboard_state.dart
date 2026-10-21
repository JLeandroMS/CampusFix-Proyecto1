import '../models/domain.dart';

/// Proyección pura del conjunto autorizado, independiente de widgets y Firebase.
class DashboardState {
  final List<Incident> items;
  DashboardState(this.items);
  int get total => items.length;
  int get open => items.where((i) => i.status.isOpen).length;
  int count(IncidentStatus status) => items.where((i) => i.status == status).length;
  Map<String, int> get byCategory {
    final values = <String, int>{};
    for (final item in items) { values.update(item.categoryId, (n) => n + 1, ifAbsent: () => 1); }
    return values;
  }
}
