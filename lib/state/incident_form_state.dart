import 'package:flutter/foundation.dart';

/// Estado de envío separado de FormState de Flutter para evitar duplicados.
class IncidentFormState extends ChangeNotifier {
  bool busy = false;
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String? error;
  Future<T?> submit<T>(Future<T> Function() action) async {
    if (busy) return null;
    busy = true;
    error = null;
    _notify();
    try {
      return await action();
    } catch (e) {
      error = 'No se completó la operación: $e';
      return null;
    } finally {
      busy = false;
      _notify();
    }
  }
}
