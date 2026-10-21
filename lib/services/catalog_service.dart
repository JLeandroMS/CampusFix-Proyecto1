import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/domain.dart';

/// Catálogos y roles: reglas de Firebase restringen escrituras al administrador.
class CatalogService {
  final FirebaseFirestore db;
  CatalogService(this.db);
  Stream<List<Category>> categories() => db.collection('categories').orderBy('name')
      .snapshots().map((s) => s.docs.map((d) => Category.fromMap(d.id, d.data())).toList());
  Stream<List<UserProfile>> users() => db.collection('users').orderBy('name')
      .snapshots().map((s) => s.docs.map((d) => UserProfile.fromMap(d.id, d.data())).toList());
  Future<void> saveCategory(String? id, String name, bool active) =>
      db.collection('categories').doc(id).set({'name': name.trim(), 'active': active});
  Future<void> setRole(String id, UserRole role) =>
      db.collection('users').doc(id).update({'role': role.name});
}
