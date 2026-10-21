import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Adaptador de identidad. Firebase administra sesiones y hashes de contraseñas.
class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  AuthService(this.auth, this.db);
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    // Repara un registro cuya escritura de perfil falló por desconexión.
    await ensureProfile();
  }
  Future<void> register(String name, String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await auth.currentUser!.updateDisplayName(name.trim());
    await ensureProfile(name: name.trim());
  }
  Future<void> ensureProfile({String? name}) async {
    final user = auth.currentUser;
    if (user == null) return;
    final ref = db.collection('users').doc(user.uid);
    await db.runTransaction((tx) async {
      if (!(await tx.get(ref)).exists) {
        tx.set(ref, {'name': name ?? user.displayName ?? 'Usuario',
          'email': user.email!, 'role': 'reportante'});
      }
    });
  }
  Future<void> updateName(String name) => db.collection('users')
      .doc(auth.currentUser!.uid).update({'name': name.trim()});
  Future<void> resetPassword(String email) => auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => auth.signOut();
}
