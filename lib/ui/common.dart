import 'package:flutter/material.dart';

import '../models/domain.dart';

String? requiredText(String? value, int min, int max) {
  final text = value?.trim() ?? '';
  return text.length < min || text.length > max
      ? 'Ingrese de $min a $max caracteres.'
      : null;
}

String dateLabel(dynamic timestamp) {
  final DateTime? date = timestamp is DateTime
      ? timestamp
      : timestamp?.toDate() as DateTime?;
  if (date == null) return 'Sincronizando…';
  final d = date.toLocal();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class StatusBadge extends StatelessWidget {
  final IncidentStatus status;
  const StatusBadge(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      IncidentStatus.resuelta || IncidentStatus.cerrada => Colors.teal,
      IncidentStatus.rechazada || IncidentStatus.cancelada => Colors.red,
      IncidentStatus.enAtencion => Colors.blue,
      _ => Colors.orange,
    };
    return Chip(
      side: BorderSide.none,
      backgroundColor: color.withValues(alpha: .13),
      label: Text(
        status.label.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Panel adaptable reutilizado en dashboard, formularios y detalle.
class Panel extends StatelessWidget {
  final Widget child;
  const Panel({required this.child, super.key});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );
}
