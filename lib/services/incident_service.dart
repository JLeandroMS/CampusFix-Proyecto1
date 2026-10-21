import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/domain.dart';
import '../models/incident_policy.dart';

/// Persistencia de incidencias. Cada mutación y su evento se confirman juntos.
/// Las transacciones detectan conflictos y generan consecutivos únicos.
class IncidentService {
  final FirebaseFirestore db;
  IncidentService(this.db);
  CollectionReference<Map<String, dynamic>> get incidents => db.collection('incidents');

  Stream<List<Incident>> watch(UserProfile user) {
    Query<Map<String, dynamic>> query = incidents;
    if (user.role == UserRole.reportante) query = query.where('creatorId', isEqualTo: user.id);
    if (user.role == UserRole.tecnico) query = query.where('technicianId', isEqualTo: user.id);
    return query.snapshots().map((s) => s.docs.map((d) => Incident.fromMap(d.id, d.data())).toList()
      ..sort((a, b) => b.number.compareTo(a.number)));
  }

  Future<String> create(UserProfile user, {required String title, required String description,
      required String categoryId, required String location}) async {
    final ref = incidents.doc();
    final counter = db.doc('counters/incidents');
    await db.runTransaction((tx) async {
      final previous = await tx.get(counter);
      final number = ((previous.data()?['value'] as int?) ?? 0) + 1;
      tx.set(counter, {'value': number, 'lastId': ref.id});
      tx.set(ref, {'number': number, 'title': title.trim(), 'description': description.trim(),
        'categoryId': categoryId, 'location': location.trim(), 'priority': 'media',
        'status': 'reportada', 'creatorId': user.id, 'technicianId': null, 'revision': 0,
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      tx.set(ref.collection('events').doc('0'), _event(user, 'reportada', null,
          'Incidencia registrada.', categoryId, 'media'));
    });
    return ref.id;
  }

  Map<String, dynamic> _event(UserProfile user, String status, String? technician,
      String note, String category, String priority) => {
    'authorId': user.id, 'at': FieldValue.serverTimestamp(), 'status': status,
    'technicianId': technician, 'note': note.trim(), 'categoryId': category, 'priority': priority,
  };

  /// Relee la revisión para impedir que una pantalla antigua sobrescriba cambios.
  Future<void> change(Incident expected, UserProfile user, {
    required IncidentStatus target, required String note,
    String? technicianId, String? categoryId, String? priority,
  }) async {
    final ref = incidents.doc(expected.id);
    await db.runTransaction((tx) async {
      final current = Incident.fromMap(ref.id, (await tx.get(ref)).data()!);
      if (current.revision != expected.revision) {
        throw StateError('El reporte cambió. Revise los datos e intente nuevamente.');
      }
      // Clasificación sin transición: exclusivamente administrador y antes de asignar.
      if (target == current.status) {
        if (user.role != UserRole.administrador ||
            ![IncidentStatus.enRevision, IncidentStatus.reabierta].contains(target) || note.trim().length < 10) {
          throw StateError('La clasificación requiere revisión o reapertura.');
        }
      } else {
        IncidentPolicy.validate(current, user, target, note);
      }
      final tech = target == IncidentStatus.reabierta ? null : technicianId ?? current.technicianId;
      final category = categoryId ?? current.categoryId;
      final level = priority ?? current.priority;
      tx.update(ref, {'status': target.name, 'technicianId': tech, 'categoryId': category,
        'priority': level, 'revision': current.revision + 1, 'updatedAt': FieldValue.serverTimestamp()});
      tx.set(ref.collection('events').doc('${current.revision + 1}'),
          _event(user, target.name, tech, note, category, level));
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> events(String id) =>
      incidents.doc(id).collection('events').orderBy('at').snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> comments(String id) =>
      incidents.doc(id).collection('comments').orderBy('at').snapshots();
  Future<void> comment(String id, UserProfile user, String text, {String? evidence}) async {
    await incidents.doc(id).collection('comments').add({'authorId': user.id,
      'at': FieldValue.serverTimestamp(), 'text': text.trim(), 'evidence': evidence});
  }
}
