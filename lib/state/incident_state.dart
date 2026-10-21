import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/domain.dart';
import '../services/incident_service.dart';

/// Estado observable por sesión. Combina filtros sin ampliar permisos de consulta.
class IncidentState extends ChangeNotifier {
  final IncidentService service;
  StreamSubscription? _subscription;
  List<Incident> items = [];
  bool loading = true;
  String? error;
  String search = '', category = '', priority = '', technician = '', status = '';
  IncidentState(this.service, UserProfile user) {
    _subscription = service.watch(user).listen((value) {
      items = value; loading = false; error = null; notifyListeners();
    }, onError: (Object e) { items = []; loading = false; error = 'No fue posible cargar las incidencias. Compruebe conexión y permisos.'; notifyListeners(); });
  }
  List<Incident> get filtered => items.where((i) {
    final haystack = '${i.code} ${i.title} ${i.description}'.toLowerCase();
    return haystack.contains(search.toLowerCase().trim()) &&
      (category.isEmpty || i.categoryId == category) &&
      (priority.isEmpty || i.priority == priority) &&
      (technician.isEmpty || i.technicianId == technician) &&
      (status.isEmpty || i.status.name == status);
  }).toList();
  void refreshFilters() => notifyListeners();
  void clearFilters() { search = ''; category = ''; priority = ''; technician = ''; status = ''; notifyListeners(); }
  @override
  void dispose() { _subscription?.cancel(); super.dispose(); }
}
