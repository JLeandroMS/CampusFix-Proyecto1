import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/domain.dart';
import '../services/auth_service.dart';

/// Mantiene la sesión y observa el rol en tiempo real; cancela listeners antiguos.
class AuthState extends ChangeNotifier {
  final AuthService service;
  StreamSubscription? _authSubscription, _profileSubscription;
  UserProfile? profile;
  bool loading = true;
  String? error;
  AuthState(this.service) {
    _authSubscription = service.auth.authStateChanges().listen((user) async {
      await _profileSubscription?.cancel();
      profile = null; error = null; loading = user != null;
      notifyListeners();
      if (user == null) return;
      try {
        await service.ensureProfile();
        if (service.auth.currentUser?.uid != user.uid) return;
        _profileSubscription = service.db.collection('users').doc(user.uid).snapshots().listen((doc) {
          profile = doc.exists ? UserProfile.fromMap(doc.id, doc.data()!) : null;
          error = doc.exists ? null : 'No se encontró el perfil.';
          loading = false; notifyListeners();
        }, onError: (Object e) { error = 'No se pudo cargar su perfil.'; loading = false; notifyListeners(); });
      } catch (_) { error = 'No se pudo preparar el perfil. Cierre sesión y reintente.'; loading = false; notifyListeners(); }
    }, onError: (Object e) { error = 'No se pudo recuperar la sesión.'; loading = false; notifyListeners(); });
  }
  @override
  void dispose() { _authSubscription?.cancel(); _profileSubscription?.cancel(); super.dispose(); }
}
