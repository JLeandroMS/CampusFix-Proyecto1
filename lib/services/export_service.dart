import 'dart:convert';

import 'package:web/web.dart' as web;

import '../models/domain.dart';

/// Exporta únicamente el conjunto autorizado y filtrado presente en pantalla.
class ExportService {
  static void incidents(List<Incident> items) {
    final json = const JsonEncoder.withIndent('  ').convert(
      items
          .map(
            (i) => {
              'consecutivo': i.code,
              'titulo': i.title,
              'categoriaId': i.categoryId,
              'ubicacion': i.location,
              'prioridad': i.priority,
              'estado': i.status.label,
              'fechaCreacion': i.createdAt?.toIso8601String(),
              'tecnicoAsignadoId': i.technicianId,
            },
          )
          .toList(),
    );
    web.HTMLAnchorElement()
      ..href = 'data:application/json;base64,${base64Encode(utf8.encode(json))}'
      ..download = 'campusfix_reportes.json'
      ..click();
  }
}
