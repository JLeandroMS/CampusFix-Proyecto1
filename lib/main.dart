import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/catalog_service.dart';
import 'services/evidence_service.dart';
import 'state/auth_state.dart';
import 'state/theme_state.dart';
import 'state/incident_state.dart';
import 'ui/auth_page.dart';
import 'ui/shell.dart';

/// Punto de composición: crea adaptadores y los inyecta; no contiene negocio.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    const emulator = bool.fromEnvironment('USE_EMULATORS');
    const project = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: emulator ? 'demo-campusfix' : '',
    );
    if (project.isEmpty) {
      throw StateError('Falta configurar Firebase. Consulte INICIAR_AQUI.md.');
    }
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment(
          'FIREBASE_API_KEY',
          defaultValue: emulator ? 'demo-api-key' : '',
        ),
        appId: String.fromEnvironment(
          'FIREBASE_APP_ID',
          defaultValue: emulator ? '1:123456:web:campusfix' : '',
        ),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
          defaultValue: '123456',
        ),
        projectId: project,
        authDomain: String.fromEnvironment(
          'FIREBASE_AUTH_DOMAIN',
          defaultValue: 'demo-campusfix.firebaseapp.com',
        ),
        storageBucket: String.fromEnvironment(
          'FIREBASE_STORAGE_BUCKET',
          defaultValue: 'demo-campusfix.appspot.com',
        ),
      ),
    );
    // En dispositivos compartidos, las incidencias no se mantienen en caché persistente.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    if (emulator) {
      const host = String.fromEnvironment(
        'EMULATOR_HOST',
        defaultValue: '127.0.0.1',
      );
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    }
    final auth = AuthService(FirebaseAuth.instance, FirebaseFirestore.instance);
    final preferences = await SharedPreferences.getInstance();
    runApp(
      MultiProvider(
        providers: [
          Provider.value(value: auth),
          Provider(create: (_) => IncidentService(FirebaseFirestore.instance)),
          Provider(create: (_) => CatalogService(FirebaseFirestore.instance)),
          Provider(create: (_) => EvidenceService(FirebaseStorage.instance)),
          ChangeNotifierProvider(create: (_) => AuthState(auth)),
          ChangeNotifierProvider(create: (_) => ThemeState(preferences)),
        ],
        child: const CampusFixApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SelectableText(
                'No fue posible iniciar CampusFix.\n$e\n\nRevise INICIAR_AQUI.md y la configuración de Firebase.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CampusFixApp extends StatelessWidget {
  const CampusFixApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CampusFix',
    debugShowCheckedModeBanner: false,
    themeMode: context.watch<ThemeState>().mode,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: const SessionGate(),
  );
  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    fontFamily: 'CampusSans',
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff176b5b),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xfff5f7fa)
        : const Color(0xff101b20),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}

/// Sustituye todo el árbol privado al cerrar sesión o cambiar de rol.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(auth.error!),
              TextButton(
                onPressed: auth.service.signOut,
                child: const Text('Volver al acceso'),
              ),
            ],
          ),
        ),
      );
    }
    if (auth.profile == null) return const AuthPage();
    final user = auth.profile!;
    return ChangeNotifierProvider(
      key: ValueKey('${user.id}-${user.role.name}'),
      create: (_) => IncidentState(context.read<IncidentService>(), user),
      child: Shell(user: user),
    );
  }
}
