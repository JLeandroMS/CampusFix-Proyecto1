import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';

/// Evidencia privada: se almacena la ruta, nunca un URL público con token.
/// La descarga autenticada vuelve a pasar por las reglas de Storage.
class EvidenceService {
  final FirebaseStorage storage;
  EvidenceService(this.storage);
  static const maxBytes = 5 * 1024 * 1024;
  Future<XFile?> pick() => openFile(acceptedTypeGroups: [const XTypeGroup(
    label: 'Fotografía JPEG o PNG', extensions: ['jpg', 'jpeg', 'png'],
    mimeTypes: ['image/jpeg', 'image/png'])]);
  Future<String> upload(String incidentId, String uid, XFile file) async {
    if (await file.length() > maxBytes) throw ArgumentError('La imagen supera 5 MB.');
    final bytes = await file.readAsBytes();
    final png = bytes.length >= 8 && bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71;
    final jpeg = bytes.length >= 3 && bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;
    if (!png && !jpeg) throw ArgumentError('Seleccione una fotografía PNG o JPEG válida.');
    final path = 'incidents/$incidentId/$uid/${DateTime.now().microsecondsSinceEpoch}.${png ? 'png' : 'jpg'}';
    await storage.ref(path).putData(bytes, SettableMetadata(contentType: png ? 'image/png' : 'image/jpeg'));
    return path;
  }
  Future<Uint8List?> load(String path) => storage.ref(path).getData(maxBytes);
  Future<void> removeOrphan(String path) => storage.ref(path).delete();
}
